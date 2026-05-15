# Kali Recon Script Collection

This folder organizes the Kali information-gathering scripts by function. Each module has its own directory, script, and short README.

Scope: local labs, your own assets, and explicitly authorized testing only.

## Directory Index

| Directory | Function | Script |
| --- | --- | --- |
| 01-domain-whois | Domain WHOIS and DNS basics | [mywhois.sh](01-domain-whois/mywhois.sh) |
| 02-subdomains | Subdomain collection | [mysub.sh](02-subdomains/mysub.sh) |
| 03-ports | Nmap port scanning | [mynmap.sh](03-ports/mynmap.sh) |
| 04-web-fingerprint | Web fingerprinting | [mywhatweb.sh](04-web-fingerprint/mywhatweb.sh) |
| 05-http-headers | HTTP header collection | [myheader.sh](05-http-headers/myheader.sh) |
| 06-robots-sitemap | robots.txt and sitemap.xml collection | [myrobots.sh](06-robots-sitemap/myrobots.sh) |
| 07-ssl-certificate | SSL certificate collection | [myssl.sh](07-ssl-certificate/myssl.sh) |
| 08-waf-cdn | WAF and CDN detection | [mywaf.sh](08-waf-cdn/mywaf.sh) |
| 09-directory-scan | Directory scanning | [mydir.sh](09-directory-scan/mydir.sh) |
| 10-js-api-extract | JavaScript and API extraction | [myjs.sh](10-js-api-extract/myjs.sh) |
| 11-vulnerability-baseline | Baseline vulnerability scanning | [myvuln.sh](11-vulnerability-baseline/myvuln.sh) |
| 12-recon-controller | Recon controller | [recon.sh](12-recon-controller/recon.sh) |
| 13-analysis | Automatic analysis | [analyze.sh](13-analysis/analyze.sh) |
| 14-html-report | HTML report generation | [report.sh](14-html-report/report.sh) |
| 15-txt-report | TXT report export | [txtreport.sh](15-txt-report/txtreport.sh) |
| 16-start-workflow | One-command workflow | [start.sh](16-start-workflow/start.sh) |
| 17-save-to-host | Save reports to host share | [savehost.sh](17-save-to-host/savehost.sh) |

## Common Order

``bash
chmod +x 01-domain-whois/mywhois.sh \
  02-subdomains/mysub.sh \
  03-ports/mynmap.sh \
  04-web-fingerprint/mywhatweb.sh \
  05-http-headers/myheader.sh \
  06-robots-sitemap/myrobots.sh \
  07-ssl-certificate/myssl.sh \
  08-waf-cdn/mywaf.sh \
  09-directory-scan/mydir.sh \
  10-js-api-extract/myjs.sh \
  11-vulnerability-baseline/myvuln.sh \
  12-recon-controller/recon.sh \
  13-analysis/analyze.sh \
  14-html-report/report.sh \
  15-txt-report/txtreport.sh \
  16-start-workflow/start.sh \
  17-save-to-host/savehost.sh
``

Run individual modules:

``bash
./01-domain-whois/mywhois.sh example.com
./02-subdomains/mysub.sh example.com
./03-ports/mynmap.sh example.com
./04-web-fingerprint/mywhatweb.sh example.com
./05-http-headers/myheader.sh example.com
./06-robots-sitemap/myrobots.sh example.com
./07-ssl-certificate/myssl.sh example.com
./08-waf-cdn/mywaf.sh example.com
./09-directory-scan/mydir.sh example.com
./10-js-api-extract/myjs.sh example.com
./11-vulnerability-baseline/myvuln.sh example.com
``

The controller scripts call sibling script names from a single working directory. To use `start.sh`, `recon.sh`, `analyze.sh`, and report scripts directly, copy them into one execution folder and adjust names or paths as needed.

## Safety

Only use these scripts for:

- Local labs
- Your own sites
- Explicitly authorized test targets
- Learning and defensive analysis

Do not use them for unauthorized public targets, password attacks, malicious uploads, destructive changes, shell access, login bypass, or lateral movement.
