from pydantic import BaseModel

from api.data.book import Book


class BookListResponse(BaseModel):
    books: list[Book]


class BooksController:
    def list(self) -> BookListResponse:
        return BookListResponse(
            books=[
                Book(
                    isbn_10="0763650862",
                    name="Maisy Goes to Preschool: A Maisy First Experiences Book",
                    unit_yen=1_246,
                    image_src="https://m.media-amazon.com/images/I/51Vvlvt9LoL._SY418_BO1,204,203,200_.jpg",
                ),
                Book(
                    isbn_10="0763610844",
                    name="Maisy Takes a Bath",
                    unit_yen=939,
                    image_src="https://m.media-amazon.com/images/I/518PwStWWSL._SY493_BO1,204,203,200_.jpg",
                ),
            ],
        )
