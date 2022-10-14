#!/bin/bash
echo "reconage" | figlet 
echo "                  Created by TheCyberW0rld"

read " Enter Subdomain , you want to enumerate:" dom
if [$dom = ]
  then 
   echo "invalid subdomain"
else 
mkdir $dom && cd $dom 
echo "Enumerating subdomains"
echo ""
echo ""
echo "starting amass"
amass enum  -d $dom -o amass.$dom.txt >> /dev/null
echo "amass has finished its task"
echo ""
echo ""
echo "Starting Sublist3r"
  sublist3r -d $dom -o sublist3r.$dom.txt >>/dev/null
echo "Sublist3r finished its task" 
echo "searching from crt.sh"
  curl -s https://crt.sh/\?q\=%25.$dom\&output\=json | jq -r ' .[].name_value' | sed 's/\*\.//g' | tee $dom.txt >>/dev/null
echo "crt.sh finished its task"
echo ""
echo "starting sub finder " 
subfinder -d $dom -v -o subfinder.$dom.txt 
echo "sub finder finished its task"
echo ""
echo ""
echo "find-domain is starting"
  findomain-linux -t $dom | tee finddomain.$dom.txt
echo "Find domain finished its task"

echo ""
echo "sorting subdomains"
echo *.txt | sort -u | subdomain.txt
echo "resolving subdomains"
  cat subdomain.txt | httpx | tee resolve.subdomains.txt >> /dev/null
echo "httpx fininshed its task"
echo ""
echo "fetching all urls with gau"
    resolve.subdomains.txt | gau | tee urls.txt >> /dev/null
echo " all url fetched with gau"


echo ""
echo "sorting urls"
    cat *.txt | egrep -v  "\.woff|\.ttf|\.svg|\.eot|\.png|\.jpeg|\.jpg|\.svg|\.css|\.ico" | sed 's/:80//g;s/:443//g' | sort -u > final.urls.txt
echo "sorting url done"
echo ""
echo "checking cnames"
      cat subdomains.txt | xargs  -P 50 -I % bash -c "dig % | grep CNAME" > cname.txt
      cat cname.txt | awk '{print $1}' | sed 's/.$//g' | httpx -silent -status-code -cdn -csp-probe -tls-probe 
echo "cname is been checked" 
echo "scanning for subdomain takeover"
  subzy --targets subdomains.txt --hide_fails 
echo "subzy finished its task" 
echo ""
echo "enumerating js files"
  cat urls.txt | grep '\.js$' | httpx -status-code -mc 200 -content-type | grep 'application/javascript' | awk '{print $1}' | tee /js.txt >/dev/null 2>&1;
echo "filtered out js file" 
echo ""
echo "scanning lfi"
  cat urls.txt | gf lfi | tee lfi.txt
echo "lfi scanning is been done"
echo "" 
echo "scanning for sql injection"
  cat urls.txt | gf sqli | tee sqli.txt
echo "Scanned urls for sql injection"
echo ""
echo "scanning for ssrf"
  cat urls.txt | gf ssrf | tee ssrf.txt
echo ""
echo "Scanning done for ssrf"
echo ""
echo "Scanning for redirect"
      cat urls.txt | gf redirect | tee redirect.txt 
echo "scanned for redirect"
echo ""
echo "scanning for ssti"
  cat urls.txt | gf ssti | tee ssti.txt 
echo "scanning finished for ssti"
echo ""
echo "scanning cve" 
  nuclei -l subdomains.txt -t /root/nuclei-templates/cves | tee cves.txt
echo "scanning cve done"
echo ""
echo "scanning for vulnerablities"
  nuclei -l subdomains.txt -t /root/nuclei-templates/vulnerabilities | tee nuclei_bugs.txt
echo "scanning for vulnerablities is done "
echo ""
echo "Scanning for misconfiguration"
  nuclei -l subdomains.txt -t /root/nuclei-templates/misconfiguration | tee nuclei_misconfiguration.txt
echo "Scanned for misconfiguration"
echo "done"
fi 
