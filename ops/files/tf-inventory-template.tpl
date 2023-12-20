[dev-machines]
%{ for host, ip in machines ~}
${host} ansible_host=${ip}

%{ endfor ~}