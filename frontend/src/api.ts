import { Configuration, DefaultApi } from "./api_client/index";
import { Book } from "./models/book";

export class ApiClient {
  private static getClient() {
    const conf = new Configuration({
      basePath: "",
    });
    return new DefaultApi(conf);
  }

  static async listBooks(): Promise<Array<Book>> {
    const client = ApiClient.getClient();
    const response = await client.getBooksApiBooksGet();
    return response.books.map((x) => {
      return new Book({
        isbn10: x.isbn_10,
        name: x.name,
        unitYen: x.unit_yen,
        imageSrc: x.image_src,
      });
    });
  }
}
