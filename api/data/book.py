from pydantic import BaseModel


class Book(BaseModel):
    isbn_10: str
    name: str
    unit_yen: float
    image_src: str
