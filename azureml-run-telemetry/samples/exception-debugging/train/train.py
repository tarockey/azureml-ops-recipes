from socket import getaddrinfo, gethostname
import ipaddress
import sys
import time
from typing import Any, Callable, Type, List
from types import TracebackType
from azureml_appinsights_logger.observability \
    import Observability, Severity


logger = Observability()


def main():
    """Example of debugging an Azure ML run remotely"""
    try:
        logger.start_span("traning_step_with_exception")
        print("Before exception")
        raise Exception("This is an exception")
    except Exception as e:
        start_debugging(logger, 5678)
        print("Debugging now")
    finally:
        logger.end_span()


def start_debugging(logger: Observability, debugging_port: int):
    import debugpy
    external_ip = get_ip()[0]
    # log a CRITICAL error - this should trigger an alert in Azure Monitor
    logger.log(f"Unhandled exception. Connect to {external_ip}:{debugging_port} for debugging.", severity=Severity.CRITICAL)
    # wait for the telemetry to be sent
    time.sleep(15)
    # wait for the debugger to be attached
    debugpy.listen((external_ip, debugging_port))
    debugpy.wait_for_client()
    debugpy.breakpoint()


def get_ip(ip_addr_proto="ipv4", ignore_local_ips=True) -> List[str]:
    # Return IP address(es) of the host machine, taken from https://stackoverflow.com/a/64530508
    # By default, this method only returns non-local IPv4 Addresses
    # To return IPv6 only, call get_ip('ipv6')
    # To return both IPv4 and IPv6, call get_ip('both')
    # To return local IPs, call get_ip(None, False)
    # Can combine options like so get_ip('both', False)

    af_inet = 2
    if ip_addr_proto == "ipv6":
        af_inet = 30
    elif ip_addr_proto == "both":
        af_inet = 0

    system_ip_list = getaddrinfo(gethostname(), None, af_inet, 1, 0)
    ip_list = []

    for ip in system_ip_list:
        ip = ip[4][0]

        try:
            ipaddress.ip_address(str(ip))
            ip_address_valid = True
        except ValueError:
            ip_address_valid = False
        else:
            if ipaddress.ip_address(ip).is_loopback and ignore_local_ips or ipaddress.ip_address(ip).is_link_local and ignore_local_ips:
                pass
            elif ip_address_valid:
                ip_list.append(str(ip))

    return ip_list


if __name__ == '__main__':
    main()
