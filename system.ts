import { Candidate } from './candidate';

interface Employee extends Candidate {
    team?: string;
}

export class InternalSystem {
    private employees: Employee[] = [];

    recordEmployee(newEmployee: Employee): string {
        this.employees.push(newEmployee);
        const {age, gender, firstName, lastName, location } = newEmployee;
        const name = `${firstName[0]}${lastName}`;
        return `
        The data of ${name} has been successfully added into the system.
        Office: ${location}
        Gender: ${gender || 'No data'}
        Age: ${age || 'No data'}
        `;
    }

    getEmployeesLength(): number {
        return this.employees.length;
    }
}