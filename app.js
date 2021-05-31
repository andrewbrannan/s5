"use strict";

const config = require("./config.js");
const Xray = require("x-ray");
const sgMail = require("@sendgrid/mail");

async function sendMail(stockText, url) {
  sgMail.setApiKey(config.sendGridKey);
  const msg = {
    to: config.email,
    from: config.email,
    subject: `S5 Stock Alert!}`,
    text: `url: ${url}\nStock status: ${stockText}`,
  };
  await sgMail.send(msg);
  console.log("Email sent");
}

async function runStockChecker(message, context) {
  // Unpack pubsub message
  const urlEncoded = message.attributes.url;

  if (!urlEncoded) {
    throw new Error("No url attribute found in pubsub message, exiting!");
  }

  // Decode URL
  const url = Buffer.from(urlEncoded, "base64").toString();

  console.log(`Running stock checker!`);
  console.log(`   url:        ${url}`);
  console.log(`   send email: ${config.sendEmail}`);
  console.log(`   recipient:  ${config.recipientEmail}`);
  console.log(`   time:       ${context.timestamp}`);

  // Check the status
  const xray = Xray();
  const status = await xray(url, ".stock");
  console.log(`Stock status: ${status}`);

  // Send an email if requested
  if (status.toLowerCase().includes("in stock")) {
    console.log("Stock found!");
    if (config.sendEmail) {
      console.log("Sending email!");
      await sendMail(status, url);
    }
  } else if (status.toLowerCase().includes("out of stock")) {
    console.log("Out of stock.");
  } else {
    console.log("Unknown stock status.");
  }
}

exports.runStockChecker = runStockChecker;
