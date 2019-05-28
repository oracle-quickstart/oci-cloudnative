export class Badge {
  constructor(node, view) {
    this.node = node;
    this.view = view;
  }

  render(value) {
    return this.view.render(this.node, value && `
      <span class="uk-badge">${value}</span>
    `);
  }
}
