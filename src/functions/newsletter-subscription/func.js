/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

const fdk = require('@fnproject/fdk');
const nodemailer = require('nodemailer');

const sendMail = async (toEmail, { host, port, user, pass, approvedSender }) => {
    const transporter = nodemailer.createTransport({
        host,
        port,
        secure: false,
        auth: {
            user,
            pass
        }
    });

    const mailOpts = {
        from: approvedSender,
        to: toEmail,
        subject: 'Hello from Mushop',
        html: 'Thanks for confirming your <b>subscription</b>!',
    };

    return transporter.sendMail(mailOpts).then((info) => {
        return { 'messageId': info.messageId };
    }, (err) => {
        return retError(err);
    });
}

const retError = msg => {
    console.error(`error: ${msg}`);
    return { error: msg };
}

fdk.handle(function (input) {
    if (!input.email) {
        return { 'error': 'email not provided' };
    }

    const { SMTP_USER, SMTP_PASSWORD, SMTP_HOST, SMTP_PORT, APPROVED_SENDER_EMAIL } = process.env;
    if (!SMTP_USER) {
        return retError('SMTP_USER environment variable not set');
    }

    if (!SMTP_PASSWORD) {
        return retError('SMTP_PASSWORD environment variable not set');
    }

    if (!SMTP_HOST) {
        return retError('SMTP_HOST environment variable not set');
    }

    if (!SMTP_PORT) {
        return retError('SMTP_PORT environment variable not set');
    }

    if (!APPROVED_SENDER_EMAIL) {
        return retError('APPROVED_SENDER_EMAIL environment variable not set');
    }

    return sendMail(input.email, {
        host: SMTP_HOST,
        port: SMTP_PORT,
        user: SMTP_USER,
        pass: SMTP_PASSWORD,
        approvedSender: APPROVED_SENDER_EMAIL,
    });
});