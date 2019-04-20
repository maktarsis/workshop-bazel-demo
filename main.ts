import { Candidate } from './candidate';
import { InternalSystem } from './system';

const system = new InternalSystem();

const candidate: Candidate = new Candidate('Max', 'Tarsis', 'Kyiv');

console.log(
    system.recordEmployee(candidate)
);

console.log(`       Employees in the system ${system.getEmployeesLength()}  `);