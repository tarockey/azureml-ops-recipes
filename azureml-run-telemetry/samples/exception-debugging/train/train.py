from socket import getaddrinfo, gethostname
import ipaddress
import sys
from typing import Any, Callable, Type, List
from types import TracebackType
from azureml_appinsights_logger.observability \
    import Observability, Severity


logger = Observability()


def main():
    """Example of debugging an Azure ML run remotely"""

    # configuring the debugger
    make_debugpy_excepthook(logger, 5678)

    try:
        logger.start_span("traning_step_with_exception")
        print("Before exception")
        raise Exception("This is an exception")
    finally:
        logger.end_span()


def make_debugpy_excepthook(logger: Observability, debugging_port: int) -> Callable[[Type[BaseException], BaseException, TracebackType], Any]:
    """
    Return an excepthook that will initialise debugpy and then call through to
    its exception handler.
    Taken from https://github.com/microsoft/debugpy/issues/723
    """
    import debugpy

    original_debugpy_excepthook = sys.excepthook

    def debugpy_excepthook(
        type_: Type[BaseException],
        value: BaseException,
        traceback: TracebackType,
    ) -> Any:
        """
        Callback called when an exception is hit and debugpy is enabled.
        """
        if not debugpy.is_client_connected():
            print(
                f"Exception thrown. Waiting for debugpy on port {debugging_port}.")

            external_ip = get_ip()[0]

            # log a CRITICAL error - this should trigger an alert in Azure Monitor
            logger.log(
                f"Unhandled exception. Connect to {external_ip}:{debugging_port} for debugging.", severity=Severity.CRITICAL)

            debugpy.listen((external_ip, debugging_port))
            debugpy.wait_for_client()

        import pydevd
        import threading

        py_db = pydevd.get_global_debugger()
        thread = threading.current_thread()
        additional_info = py_db.set_additional_thread_info(thread)
        additional_info.is_tracing += 1
        try:
            arg = (type_, value, traceback)
            py_db.stop_on_unhandled_exception(
                py_db, thread, additional_info, arg)
        finally:
            additional_info.is_tracing -= 1
        original_debugpy_excepthook(type_, value, traceback)

    return debugpy_excepthook


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
