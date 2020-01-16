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

    const { user, pass, host, port, approvedSender } = process.env;
    if (!user) {
        return retError('SMTP_USER environment variable not set');
    }

    if (!pass) {
        return retError('SMTP_PASSWORD environment variable not set');
    }

    if (!host) {
        return retError('SMTP_HOST environment variable not set');
    }

    if (!port) {
        return retError('SMTP_PORT environment variable not set');
    }

    if (!approvedSender) {
        return retError('APPROVED_SENDER_EMAIL environment variable not set');
    }

    return sendMail(input.email, {
        host,
        port,
        user,
        pass,
        approvedSender
    });
});