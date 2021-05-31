const config = require("./config.js");

const fixtures = {};
const { runStockChecker } = require("./app");

jest.mock("x-ray");
jest.mock("@sendgrid/mail");

const Xray = require("x-ray");
const sgMail = require("@sendgrid/mail");

beforeEach(() => {
    // https://test.com base64 === "aHR0cHM6Ly90ZXN0LmNvbQ=="
    fixtures.pubsub_message = {
        attributes: { url: "aHR0cHM6Ly90ZXN0LmNvbQ==" },
    };
    fixtures.context = { timestamp: "2018-04-09T07:56:12.975Z" };

    config.sendEmail = true;
    config.sendGridKey = "DUMMYKEY";
});

test("runner to error if no url in message", async () => {
    fixtures.pubsub_message = { attributes: { notAUrl: 2 } };
    await expect(async () => {
        await runStockChecker(fixtures.pubsub_message, fixtures.context);
    }).rejects.toThrowError();
});

test("runner detects oos", async () => {
    Xray.mockReturnValue(async (url, id) => {
        expect(url).toBe("https://test.com");
        expect(id).toBe(".stock");
        return "Out of stock";
    });
    await runStockChecker(fixtures.pubsub_message, fixtures.context);
    expect(sgMail.send).toHaveBeenCalledTimes(0);
});

test("runner sends email if not OOS", async () => {
    Xray.mockReturnValue(async (url, id) => {
        expect(url).toBe("https://test.com");
        expect(id).toBe(".stock");
        return "5 in stock";
    });
    await runStockChecker(fixtures.pubsub_message, fixtures.context);
    expect(sgMail.send).toHaveBeenCalledTimes(1);
    expect(sgMail.setApiKey).toHaveBeenCalledWith("DUMMYKEY");
    expect(sgMail.send).toHaveBeenCalledTimes(1);
});
