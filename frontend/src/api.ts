import { Configuration, DefaultApi } from "./api_client/index";
import { Book } from "./models/book";

export class ApiClient {
  authToken: string;

  constructor(props: { authToken: string }) {
    this.authToken = props.authToken;
  }

  private getClient() {
    const conf = new Configuration({
      basePath: "",
      accessToken: this.authToken,
    });
    return new DefaultApi(conf);
  }

  async listBooks(): Promise<Array<Book>> {
    const client = this.getClient();
    const response = await client.getBooksApiBooksGet();
    return response.books.map(
      (x: { isbn_10: any; name: any; unit_yen: any; image_src: any }) => {
        return new Book({
          isbn10: x.isbn_10,
          name: x.name,
          unitYen: x.unit_yen,
          imageSrc: x.image_src,
        });
      }
    );
  }
}
