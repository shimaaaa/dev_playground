import { ApiClient } from './api'
import { Book }  from './models/book';
import { useCallback, useEffect, useState } from "react";
import {Card, CardHeader, CardBody, Image} from "@nextui-org/react";
import { Auth } from 'aws-amplify';

const isError = (error: unknown): error is Error => {
  return error instanceof Error;
};

function BookItem(props: { book: Book }) {
  const book = props.book;
  Auth.currentSession().then(console.log);
  return (
    <Card className="py-4 max-w-[400px]">
      <CardHeader className="pb-0 pt-2 px-4 flex-col items-start">
        <h4 className="font-bold text-large text-center">{ book.name }</h4>
        <small className="text-default-500 text-right">¥{ book.unitYen }</small>
      </CardHeader>
      <CardBody className="overflow-visible py-2">
        <Image
          alt="book image"
          className="object-cover rounded-xl"
          src={book.imageSrc}
          width={270}
        />
      </CardBody>
    </Card>
  );
  // return <li key={props.book.isbn10}>{props.book.name}</li>
}

export function BookList() {
  const [books, setBooks] = useState<Book[]>([]);
  const [error, setError] = useState<Error | undefined>(undefined);

  const fetchBooks = useCallback(async () => {
    try {
      const books = ApiClient.listBooks();
      setBooks(await books);
    } catch (e) {
      if (isError(e)) {
        setError(e);
      }
    }
  }, []);

  useEffect(() => {
    fetchBooks();
  }, [fetchBooks]);

  if (error) {
    return <div>{error.message}</div>;
  }
  const bookItems = books.map(book => <BookItem book={book}/>);
  return (
    <>
      <h1 className="text-3xl font-bold underline">
        Books
      </h1>
      <div className='grid grid-cols-1 gap-4'>
        {bookItems}
      </div>
    </>
  );
}
