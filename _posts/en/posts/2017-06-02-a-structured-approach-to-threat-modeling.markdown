---
layout: post
title: "A structured approach to Threat Modeling"
name: a-structured-approach-to-threat-modeling
date: 2017-06-02 07:45
categories:
- security
---

I recently stumbled on [this article](https://blog.docker.com/2017/05/docker-security-pycon-threat-modeling-state-machines/) and [its associated video](https://www.youtube.com/watch?v=n8l0xTdLnA8) which provide a very structured approach to threat modeling & security. Below is my summary of these excellent resources.

---------------

## Table of Contents
{:.no_toc}
* Table of Contents will appear here.
{:toc}

---------------

## Data collection

Gather information about the system considered and its:

1. external dependencies
2. entry and exit points
3. assets
4. trust levels and boundaries, i.e. where data is elevated in privilege
5. data flows

## Analysis

Identify, classify and prioritise vulnerabilities.
For example, where do we have flows between processes without any trust boundary, and what are the associated risks?

### STRIDE classification

For each [STRIDE](https://en.wikipedia.org/wiki/STRIDE_(security)) category, look for behaviour permitted by the system which creates a vulnerability.
A vulnerability may belong to more than one category.

1. Spoofing: an entity pretending to be something it is not, generally by capturing a legitimate user’s credentials, e.g.: [brute force](https://owasp.org/www-community/attacks/Brute_force_attack), [CSRF](https://owasp.org/www-community/attacks/csrf).
2. Tampering: the modification of data persisted within the system, e.g.: [SQL injection](https://www.owasp.org/index.php/SQL_Injection), [MITM](https://www.owasp.org/index.php/Man-in-the-middle_attack), [DNS cache poisoning](https://www.cs.cornell.edu/~shmat/shmat_securecomm10.pdf).
3. Repudiation: the ability to perform operations that cannot be tracked, or for which the attacker can actively cover their tracks, e.g.: prove who did `rm -fr /var/log`.
4. Information Disclosure: the acquisition of data by a trust level that should not have access to it, e.g.: bad messaging, [SQL injection](https://www.owasp.org/index.php/SQL_Injection), [MITM](https://www.owasp.org/index.php/Man-in-the-middle_attack).
5. Denial of Service: preventing legitimate users from accessing the service, e.g.: [SQL injection](https://www.owasp.org/index.php/SQL_Injection), [DDOS](https://www.owasp.org/index.php/Denial_of_Service).
6. Elevation of Privilege: an attack aimed at allowing an entity of lower trust level to perform actions restricted to a higher trust level, e.g.: [SQL injection](https://www.owasp.org/index.php/SQL_Injection), [CSRF](https://owasp.org/www-community/attacks/csrf).

Each vulnerability is then risk-assessed by "severity" and "probability".
This can however be a bit vague, so using the below scoring system, [DREAD](https://en.wikipedia.org/wiki/DREAD_(risk_assessment_model)), can help be more objective & systematic.
A scale of your choice (e.g.: from 1 to 10) can be used for each criteria.

### DREAD scoring

1. Damage (Severity): how bad would the financial and reputation damage be to your organisation and its users.
2. Reproducibility (Probability): how easy is it to trigger the vulnerability. Most vulnerabilities will score high here but those that, for example, involve timing attacks would generally receive lower vulnerabilities as they may not be triggered 100% of the time.
3. Exploitability (Probability): a measure of what resources are required to use the attack. The lowest score would generally be reserved for nation states, while a high score might indicate the attack could be done through something as simple as URL manipulation in a browser.
4. Affected Users (Severity): a measure of how many users are affected by the attack. For example, maybe it only affects a specific class of user.
5. Discoverability (Probability): how easy it is to uncover the vulnerability. A high score would indicate it is easily findable through standard web scraping tools and open source [pentest tools](https://www.owasp.org/index.php/Category:Penetration_Testing_Tools). At the other end of the scale, a vulnerability requiring intimate knowledge of a system’s internals would likely score low.

## Remediation

For each vulnerability and each aspect of it, consider the most appropriate remediation:

1. Spoofing –> Authentication: of users (e.g. two-factor authentication), of requests (e.g. CSRF tokens), etc.
2. Tampering –> Integrity controls: validate input, checksums (both of data at rest and in transit), etc.
3. Repudiation –> Non-Repudiation: append-only audit logs, digital signatures, etc.
4. Information Disclosure –> Confidentiality: encryption (both at rest and in transit, e.g.: using TLS), redaction (e.g.: hide passwords when rendering settings), configuration (e.g.: logs should not print passwords).
5. Denial of Service –> Availability: more replicas, rate limits, recovery protocol (e.g.: self-serviced password reset to avoid users self-denying service), etc.
6. Elevation of Privilege –> Authorisation: well-defined authorisation model, least privilege, re-authentication.

## Conclusion

Repeating the cycle:

1. Data collection
2. Analysis
3. Remediation

at various levels:

- individual components & libraries,
- applications,
- infrastructure,

one can have a very effective & systematic approach to security.

## Resources

- Threat modeling:

    - [https://www.owasp.org/index.php/Threat_Risk_Modeling](https://www.owasp.org/index.php/Threat_Risk_Modeling)
    - [https://www.owasp.org/index.php/Application_Threat_Modeling](https://www.owasp.org/index.php/Application_Threat_Modeling)

- State machines and how to build simpler, more robust & more secure software:

    - [https://www.youtube.com/watch?v=MtHscXjWbVs](https://www.youtube.com/watch?v=MtHscXjWbVs)
    - [https://github.com/glyph/automat](https://github.com/glyph/automat)
    - [https://clusterhq.com/2013/12/05/what-is-a-state-machine/](https://clusterhq.com/2013/12/05/what-is-a-state-machine/)
    - [https://clusterhq.com/2014/01/07/benefits-state-machine/](https://clusterhq.com/2014/01/07/benefits-state-machine/)
    - [https://clusterhq.com/2014/03/03/unit-testing-state-machines/](https://clusterhq.com/2014/03/03/unit-testing-state-machines/)
    - [https://clusterhq.com/2014/05/15/isolating-side-effects-state-machines/](https://clusterhq.com/2014/05/15/isolating-side-effects-state-machines/)