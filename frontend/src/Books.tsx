import { ApiClient } from './api'
import { Book } from './models/book';
import { useCallback, useEffect, useState } from "react";

const isError = (error: unknown): error is Error => {
  return error instanceof Error;
};

export function Books() {
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
  return (
    <div>
      {books.map((book) => (
        <li key={book.isbn10}>{book.name}</li>
      ))}
    </div>
  );
}
