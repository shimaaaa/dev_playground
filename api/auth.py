from fastapi import Request
from fastapi.openapi.models import HTTPBearer as HTTPBearerModel
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer


class JWTBearer(HTTPBearer):
    def __init__(
        self,
    ) -> None:
        self.model = HTTPBearerModel(bearerFormat=None, description=None)
        self.scheme_name = self.__class__.__name__
        self.auto_error = True

    async def __call__(
        self,
        request: Request,
    ) -> HTTPAuthorizationCredentials:
        return await super().__call__(request)


def verify_user(request: Request) -> str:
    print(request.headers.get("Authorization"))
    return "hoge"
