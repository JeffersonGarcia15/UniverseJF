// credits to https://www.w3resource.com/javascript/form/email-validation.php

export default function ValidateEmail(mail) {
    return (/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/.test(mail))
}