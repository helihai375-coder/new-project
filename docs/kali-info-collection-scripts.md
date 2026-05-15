# Kali Information-Gathering Scripts

The original notes have been split into `tools/kali-recon/`. Each function has a separate directory containing the script and a short README.

## Classification

- `tools/kali-recon/01-domain-whois/`: Domain WHOIS and DNS basics
- `tools/kali-recon/02-subdomains/`: Subdomain collection
- `tools/kali-recon/03-ports/`: Nmap port scanning
- `tools/kali-recon/04-web-fingerprint/`: Web fingerprinting
- `tools/kali-recon/05-http-headers/`: HTTP header collection
- `tools/kali-recon/06-robots-sitemap/`: robots.txt and sitemap.xml collection
- `tools/kali-recon/07-ssl-certificate/`: SSL certificate collection
- `tools/kali-recon/08-waf-cdn/`: WAF and CDN detection
- `tools/kali-recon/09-directory-scan/`: Directory scanning
- `tools/kali-recon/10-js-api-extract/`: JavaScript and API extraction
- `tools/kali-recon/11-vulnerability-baseline/`: Baseline vulnerability scanning
- `tools/kali-recon/12-recon-controller/`: Recon controller
- `tools/kali-recon/13-analysis/`: Automatic analysis
- `tools/kali-recon/14-html-report/`: HTML report generation
- `tools/kali-recon/15-txt-report/`: TXT report export
- `tools/kali-recon/16-start-workflow/`: One-command workflow
- `tools/kali-recon/17-save-to-host/`: Save reports to host share

## Usage Notes

1. Run only in local labs, on your own assets, or in explicitly authorized environments.
2. Read each module README before running it.
3. For scripts that scan or make network requests, keep target scope and rate controlled.
4. Controller scripts contain cross-script calls, so confirm file names and paths before direct use.

## Safety Boundary

Do not use these scripts against unauthorized public targets or for password attacks, destructive changes, shell access, login bypass, unauthorized data access, or lateral movement.
