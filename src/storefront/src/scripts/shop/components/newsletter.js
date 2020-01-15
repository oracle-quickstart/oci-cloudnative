/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
import { Mu, MuMx, attrToSelector } from '../../mu';
import { ViewTemplateMixin } from '../helper/viewmx';
import { MxCtxInsulator } from '../helper/mixins';

const MU_NEWSLETTER_SUBSCRIPTION = "mu-newsletter-subscription";

class NewsletterSubscription extends MuMx.compose(null,
    MxCtxInsulator,
    ViewTemplateMixin,
) {
    onMount() {
        super.onMount();
        this.render({
            // Bind the subscribe() to the `subscribe` that can be used in a template
            subscribe: this.subscribe.bind(this)
        });
    }

    subscribe() {
        const { http, ui } = this.mu;
        const inp = this.node.querySelector('input');
        const email = inp.value;

        http.post('/newsletter', { email })
            .then(() => ui.notification(`Thank you ${email} for subscribing!`, {
                status: 'success',
                timeout: 2e3
            })).catch(err => ui.notification(err, 'danger'))
    }
}

// Bind the NewsletterSubscription class to MU_NEWSLETTER_SUBSCRIPTION attribute
export default Mu.micro(NewsletterSubscription, attrToSelector(MU_NEWSLETTER_SUBSCRIPTION));
