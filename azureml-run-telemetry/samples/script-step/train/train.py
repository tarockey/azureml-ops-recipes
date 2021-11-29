from azureml_appinsights_logger.observability \
    import Observability, Severity
import random


logger = Observability()


def main():
    """Minimum example to run the Observability logger inside Azure ML run"""
    try:
        logger.start_span("traning_step")
        logger.log_metric(name="accuracy", value=random.random())
        logger.log_metric(name="precision",
                          value=random.random(), log_parent=True)
        logger.log("Demo AML error", severity=Severity.ERROR)
    finally:
        logger.end_span()


if __name__ == '__main__':
    main()
