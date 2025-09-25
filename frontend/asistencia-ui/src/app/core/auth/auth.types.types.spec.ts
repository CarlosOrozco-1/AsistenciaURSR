import { TestBed } from '@angular/core/testing';

import { AuthTypesTypes } from './auth.types.types';

describe('AuthTypesTypes', () => {
  let service: AuthTypesTypes;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(AuthTypesTypes);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
