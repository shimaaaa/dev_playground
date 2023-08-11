from logging import getLogger
from typing import Any

import requests
from fastapi import HTTPException, Request
from fastapi.openapi.models import HTTPBearer as HTTPBearerModel
from fastapi.security import HTTPBearer
from jose import jwk, jwt
from jose.backends.base import Key
from jose.exceptions import JWKError, JWTError
from pydantic import BaseModel
from pydantic_settings import BaseSettings
from starlette.status import HTTP_403_FORBIDDEN

logger = getLogger(__name__)

JWK = dict[str, str]


class JWKS(BaseModel):
    keys: list[JWK]


class User(BaseModel):
    id: str
    email: str


class JWTAuthorizationCredentials(BaseModel):
    jwt_token: str
    header: dict[str, str]
    claims: dict[str, Any]
    signature: str
    message: str

    @property
    def header_kid(self) -> str:
        return self.header["kid"]

    @property
    def claims_sub(self) -> str:
        return self.claims["sub"]

    @property
    def claims_email(self) -> str:
        return self.claims["email"]


class JWKSetting(BaseSettings):
    jwks_url: str
    jwt_issuer: str
    oidc_client_id: str


class JWTBearer(HTTPBearer):
    def __init__(
        self,
    ) -> None:
        self.model = HTTPBearerModel(bearerFormat=None, description=None)
        self.scheme_name = self.__class__.__name__
        self.auto_error = True
        setting = JWKSetting()
        self.jwt_issuer = setting.jwt_issuer
        self.oidc_client_id = setting.oidc_client_id
        jwks = JWKS.model_validate(
            requests.get(setting.jwks_url, timeout=30).json(),
        )
        self.kid_jwk = {jwk["kid"]: jwk for jwk in jwks.keys}

    def _get_key(self, kid: str) -> Key:
        try:
            return jwk.construct(self.kid_jwk[kid])
        except KeyError as e:
            msg = "get jwk key"
            raise JWKError(msg) from e

    def _verify_jwk_token(
        self,
        token: str,
        jwt_credentials: JWTAuthorizationCredentials,
    ) -> bool:
        kid = jwt_credentials.header_kid
        key = self._get_key(kid=kid)
        try:
            jwt.decode(
                token=token,
                key=key,
                issuer=self.jwt_issuer,
                audience=self.oidc_client_id,
            )
        except JWTError as e:
            logger.warning(e)
            return False
        else:
            return True

    async def __call__(
        self,
        request: Request,
    ) -> User:
        credentials = await super().__call__(request)
        jwt_token = credentials.credentials
        message, signature = jwt_token.rsplit(".", 1)
        try:
            jwt_credentials = JWTAuthorizationCredentials(
                jwt_token=jwt_token,
                header=jwt.get_unverified_header(jwt_token),
                claims=jwt.get_unverified_claims(jwt_token),
                signature=signature,
                message=message,
            )
        except (JWKError, JWTError) as exc:
            raise HTTPException(
                status_code=HTTP_403_FORBIDDEN,
                detail="invalid token",
            ) from exc
        if not self._verify_jwk_token(token=jwt_token, jwt_credentials=jwt_credentials):
            raise HTTPException(status_code=HTTP_403_FORBIDDEN, detail="invalid token")

        return User(
            id=jwt_credentials.claims_sub,
            email=jwt_credentials.claims_email,
        )
