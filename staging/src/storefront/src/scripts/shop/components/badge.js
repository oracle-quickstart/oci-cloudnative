/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

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
