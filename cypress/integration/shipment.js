context("Shipment", () => {
  before(() => {
    cy.login("Administrator", "admin");
    cy.visit("/desk");
  });

  beforeEach(() => {
    cy.session("user-session", () => {
      cy.login("Administrator", "admin");
      cy.visit("/desk");
    });
  });

  it("test not yet defined", () => {});
});
