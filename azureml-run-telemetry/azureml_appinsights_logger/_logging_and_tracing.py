import logging
import threading
import os 

from opencensus.trace import config_integration, execution_context
from opencensus.trace.propagation.trace_context_http_header_format import TraceContextPropagator
from opencensus.trace.span import Span, SpanKind
from opencensus.trace.tracer import Tracer, SpanContext
from opencensus.trace.tracers.noop_tracer import NoopTracer
from opencensus.trace.samplers import ProbabilitySampler
from opencensus.stats import stats as stats_module
from opencensus.ext.azure.log_exporter import AzureLogHandler
from opencensus.ext.azure.trace_exporter import AzureExporter
from opencensus.ext.azure import metrics_exporter

from azureml.core.run import Run


__LOGGING__FORMAT__:str = "%(asctime)s | %(levelname)s | %(name)s | %(message)s"

class PipelineTracing:

    __traceparent_header_name: str = "opencensus_traceparent"

    __az_trace_lock = threading.Lock()
    __tracing_initialized = False
    __az_role_name: str = ""
    __az_run_id: str = ""

    __az_trace_exporter: AzureExporter = None
    __az_metrics_exporter: metrics_exporter.MetricsExporter = None
    __az_log_handler: AzureLogHandler = None

    __azureml_run_tracer: Tracer = None

    @staticmethod
    def initialize(
                app_insights_connection_string: str,
                export_interval: float = 10.0):
        if PipelineTracing.__tracing_initialized:
            return
        with PipelineTracing.__az_trace_lock:
            if PipelineTracing.__tracing_initialized:
                return
            run = Run.get_context()
            PipelineTracing.__az_role_name = str(
                run.name) if run.name is not None else str(run.id)
            PipelineTracing.__az_run_id = str(run.id)
            config_integration.trace_integrations(["threading", "logging"])
            
            # workaround for this issue https://github.com/census-instrumentation/opencensus-python/issues/442:
            default_or_current_tracer = execution_context.get_opencensus_tracer()
            if isinstance(default_or_current_tracer, NoopTracer):
                if not hasattr(default_or_current_tracer, "sampler"):
                    default_or_current_tracer.sampler = None
                if not hasattr(default_or_current_tracer, "exporter"):
                    default_or_current_tracer.exporter = None
                if not hasattr(default_or_current_tracer, "propagator"):
                    default_or_current_tracer.propagator = None

            currentLevel = logging.root.level
            logging.basicConfig(format=__LOGGING__FORMAT__,
                                level=currentLevel)
            if app_insights_connection_string is None:
                app_insights_connection_string = os.environ.get("APPINSIGHTS_CONNECTION_STRING", None)
            if app_insights_connection_string and app_insights_connection_string != "":
                PipelineTracing.__az_log_handler = AzureLogHandler(
                    connection_string=app_insights_connection_string,
                    export_interval=export_interval)
                PipelineTracing.__az_log_handler.name = PipelineTracing.__az_role_name
                PipelineTracing.__az_log_handler.add_telemetry_processor(
                    PipelineTracing.telemetry_processor_callback_function)
                PipelineTracing.__az_trace_exporter = AzureExporter(
                    connection_string=app_insights_connection_string,
                    export_interval=export_interval)
                PipelineTracing.__az_metrics_exporter = metrics_exporter.new_metrics_exporter(
                    connection_string=app_insights_connection_string,
                    export_interval=export_interval)
                PipelineTracing.__az_trace_exporter.add_telemetry_processor(
                    PipelineTracing.telemetry_processor_callback_function)

                # register metrics exporter
                PipelineTracing.__az_metrics_exporter.add_telemetry_processor(
                    PipelineTracing.telemetry_processor_callback_function)
                stats_module.stats.view_manager.register_exporter(
                    PipelineTracing.__az_metrics_exporter)
            else:
                logging.warning("No Application Insights connection string provided. OpenCensus integration was not initialized.")

            PipelineTracing.__tracing_initialized = True


    def telemetry_processor_callback_function(envelope) -> None:
        envelope.tags["ai.cloud.role"] = PipelineTracing.__az_role_name
        envelope.tags["aml_run_id"] = PipelineTracing.__az_run_id


    @staticmethod
    def get_run_tracer(
            force_new: bool = True,
            tracing_sample_rate: float = 1.0) -> Tracer:
        """Creates a Tracer object with the pipeline context

        Args:
            tracing_sample_rate (float, optional): Target sampling rate for PropabilitySample. Defaults to 1.0.

        Returns:
            Tracer: Opencensus Tracer object
        """
        if not PipelineTracing.__tracing_initialized:
            raise RuntimeError("pipeline_tracing_initialize must be called first.")

        if PipelineTracing.__azureml_run_tracer is not None and not force_new:
            return PipelineTracing.__azureml_run_tracer

        with PipelineTracing.__az_trace_lock:
            if PipelineTracing.__azureml_run_tracer is not None and not force_new:
                return PipelineTracing.__azureml_run_tracer

            run = Run.get_context()
            experiment_run = run
            while run.parent is not None:
                experiment_run = experiment_run.parent

            exp_props = experiment_run.get_properties()
            root_span_id = None
            context = None
            if PipelineTracing.__traceparent_header_name not in exp_props:
                try:
                    root_span_id = SpanContext.generate_span_id()
                    context = SpanContext(
                        trace_id=experiment_run.id, span_id=root_span_id)
                    tracecontext = TraceContextPropagator().to_headers(context)
                    trace_parent = tracecontext["traceparent"]
                    experiment_run.add_properties(
                        {PipelineTracing.__traceparent_header_name: trace_parent})
                except:
                    root_span_id = None
                exp_props = experiment_run.get_properties()
            if root_span_id is None:
                if PipelineTracing.__traceparent_header_name in exp_props:
                    context = TraceContextPropagator().from_headers({"traceparent": exp_props[PipelineTracing.__traceparent_header_name]})
                
            tracer = Tracer(
                span_context=context,
                sampler=ProbabilitySampler(tracing_sample_rate),
                exporter=PipelineTracing.__az_trace_exporter)
            if PipelineTracing.__azureml_run_tracer is None:
                PipelineTracing.__azureml_run_tracer = tracer

        return tracer


    @staticmethod
    def aml_step_span() -> Span:
        span = PipelineTracing.get_run_tracer().span(Run.get_context().id)
        span.span_kind = SpanKind.SERVER


    @staticmethod
    def make_run_logger() -> 'PipelineLoggerAdapter':
        """Creates a Tracer object with the pipeline context

        Returns:
            logger: PipelineLoggerAdapter object
        """
        if not PipelineTracing.__tracing_initialized:
            raise RuntimeError(
                "PipelineTracing.initialize must be called first.")
        logger = logging.getLogger(PipelineTracing.__az_role_name)
        # configure handlers, so get no duplicates
        if not logger.handlers or len(logger.handlers) == 0:
            handler = logging.StreamHandler()
            formatter = logging.Formatter(__LOGGING__FORMAT__)
            handler.setFormatter(formatter)
            logger.addHandler(handler)
        logger.propagate = False
        if PipelineTracing.__az_log_handler and PipelineTracing.__az_role_name not in [h.name for h in logger.handlers]:
            logger.addHandler(PipelineTracing.__az_log_handler)

        logger.setLevel(logging.INFO)
        adapter = PipelineLoggerAdapter(logger)
        return adapter


class PipelineLoggerAdapter(logging.LoggerAdapter):
    """
    An adapter for loggers which makes it easier to specify contextual
    information in logging output.
    """

    _PIPELINE_ATTRIBUTES_KEY = "custom_dimensions"


    def __init__(self, logger: logging.Logger):
        self.pipeline_attributes = {}
        super().__init__(logger, None)

        run = Run.get_context()
        experiment_run = run
        while run.parent is not None:
            experiment_run = experiment_run.parent
        self.pipeline_attributes["aml_workspace_id"] = str(run.experiment.workspace_id)
        if experiment_run.experiment is not None:
            self.pipeline_attributes["aml_experiment_id"] = str(experiment_run.experiment.id)
            self.pipeline_attributes["aml_experiment_name"] = str(experiment_run.experiment.name)
        self.pipeline_attributes["aml_experiment_run_id"] = str(experiment_run.id)
        self.pipeline_attributes["aml_run_id"] = str(run.id)
        exp_props = experiment_run.get_properties()
        if "azureml.pipelineid" in exp_props:
            self.pipeline_attributes["aml_pipeline_id"] = str(exp_props["azureml.pipelineid"])


    def process(self, msg, kwargs):
        if "extra" in kwargs:
            if PipelineLoggerAdapter._PIPELINE_ATTRIBUTES_KEY in kwargs["extra"]:
                attrs = kwargs["extra"][PipelineLoggerAdapter._PIPELINE_ATTRIBUTES_KEY]
                attrs = {**self.pipeline_attributes, **attrs}
                kwargs["extra"][PipelineLoggerAdapter._PIPELINE_ATTRIBUTES_KEY] = attrs
        else:
            kwargs["extra"] = {PipelineLoggerAdapter._PIPELINE_ATTRIBUTES_KEY: self.pipeline_attributes}
        return msg, kwargs


    def addHandler(self, hdlr):
        self.logger.addHandler(hdlr)


    def removeHandler(self, hdlr):
        self.logger.removeHandler(hdlr)


    def addFilter(self, log_filter):
        self.logger.addFilter(log_filter)


    def removeFilter(self, log_filter):
        self.logger.removeFilter(log_filter)

