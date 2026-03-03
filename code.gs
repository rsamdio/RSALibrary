function doPost(e) {
  var sheet = SpreadsheetApp.openById("1h_S0yRtZODd5nk9oqq93-RLVwwAm2GfpNCQxfafhnak").getSheetByName("Requests");

  var name = e.parameter.name || "";
  var email = e.parameter.email || "";
  var club = e.parameter.club || "";
  var district = e.parameter.district || "";
  var resourceGroup = e.parameter.resource_group || "";
  var details = e.parameter.resource_details || "";
  var referenceLink = e.parameter.reference_link || "";
  var managerEmail = "rotaract3191drr@gmail.com";

  sheet.appendRow([
    new Date(),
    name,
    email,
    club,
    district,
    resourceGroup,
    details,
    referenceLink
  ]);

  if (email) {
    var subject = "Thank you for your Rotaract Library request";
    var body =
      "Dear " + (name || "Rotaractor") + ",\n\n" +
      "Thank you for submitting a request to the Rotaract Library. Here is a copy of what we received:\n\n" +
      "Name: " + name + "\n" +
      "Email: " + email + "\n" +
      "Club: " + club + "\n" +
      "District: " + district + "\n" +
      "Resource Group: " + resourceGroup + "\n" +
      "Details: " + details + "\n" +
      "Reference Link: " + referenceLink + "\n\n" +
      "The Rotaract Library team will review your request and follow up if we need more information.\n\n" +
      "Yours in Rotaract,\n" +
      "Rotaract South Asia MDIO";

    MailApp.sendEmail({
      to: email,
      cc: managerEmail,
      subject: subject,
      body: body,
      name: "Rotaract South Asia MDIO - Online"
    });
  }

  return ContentService
    .createTextOutput("OK")
    .setMimeType(ContentService.MimeType.TEXT);
}

