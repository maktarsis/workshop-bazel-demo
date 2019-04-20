import { genId } from "./genId";

type gender = 'M' | 'F';

export interface Person {
    firstName: string;
    lastName: string;
    location: string;
    gender?: gender;
    age?: number;
}

export class Candidate implements Person {
    public id: string;

    constructor(
        public firstName: string,
        public lastName: string,
        public location: string,
        public gender?: gender,
        public age?: number
    ) {
        this.id = genId();
        this.age = age || 0;
    }
}