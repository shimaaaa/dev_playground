export class Book {
  isbn10: string;
  name: string;
  unitYen: number;
  imageSrc: string;

  constructor(props: {
    isbn10: string;
    name: string;
    unitYen: number;
    imageSrc: string;
  }) {
    this.isbn10 = props.isbn10;
    this.name = props.name;
    this.unitYen = props.unitYen;
    this.imageSrc = props.imageSrc;
  }
}
