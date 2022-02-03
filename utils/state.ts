export class State {
  public _state: {};

  constructor() {
    this._state = {};
  }

  get(key: any) {
    return (this as any)._state[key];
  }

  set(key: any, value: any) {
    (this as any)._state[key] = value;
  }

  getAll() {
    return this._state;
  }
}
