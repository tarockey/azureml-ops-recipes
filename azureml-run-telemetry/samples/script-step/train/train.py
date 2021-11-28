from azureml_appinsights_logger.observability \
    import Observability, Severity
import time


logger = Observability()


def main():
    """Minimum example to run the Observability logger inside Azure ML run"""
    try:
        logger.start_span("traning_step")
        logger.log("Demo AML error", severity=Severity.ERROR)
        logger.log_metric(name="accuracy", value=1)
        logger.log_metric(name="precision", value=0.6, log_parent=True)
    finally:
        logger.end_span()


if __name__ == '__main__':
    main()
