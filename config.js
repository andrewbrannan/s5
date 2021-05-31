require("dotenv").config();

var config = {};

config.recipientEmail = process.env.RECIPIENT_EMAIL;
config.sendEmail = (process.env.SEND_EMAIL || "false") === "true";
config.sendGridKey = process.env.SENDGRID_KEY;

module.exports = config;
