from dotenv import load_dotenv
import requests
from azureml.core.authentication import InteractiveLoginAuthentication
from azureml.core \
    import Workspace, ScriptRunConfig, Experiment, Environment # noqa E402
from azureml.core.compute import AmlCompute, ComputeTarget

# comment below when package is installed from PyPI
import sys
import os
libpath = os.path.abspath(os.path.join(sys.path[0], '..', '..'))
sys.path.append(libpath)

from azureml_appinsights_logger.observability import Observability # noqa E402
from azureml_appinsights_logger.logger_interface import Severity # noqa E402


logger = Observability()
run_on_local = False


def main():
    """
    Minimum sample to use the Observability logger
    in Azure ML Run or alone
    """

    source_directory = os.path.abspath(os.path.join(sys.path[0], "..", ".."))

    load_dotenv()
    workspace_name = os.environ.get("AML_WORKSPACE_NAME")
    resource_group = os.environ.get("AML_RESOURCE_GROUP")
    subscription_id = os.environ.get("SUBSCRIPTION_ID")
    compute_name = os.environ.get("AML_TRAIN_COMPUTE")

    auth = InteractiveLoginAuthentication()
    aml_ws = Workspace.get(
        name=workspace_name,
        subscription_id=subscription_id,
        resource_group=resource_group,
        auth=auth,
    )

    # Submit an Azure ML Run which uses the logger
    aml_exp = Experiment(aml_ws, 'test_logger_4')
    aml_env = Environment.from_conda_specification(
        'test_logger_env', f'{source_directory}/samples/conda_dependency.yml')

    # Getting Application Insights linked to the workspace
    aicxn = 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    app_insights_resource = aml_ws.get_details()["applicationInsights"].replace(
        "/providers/Microsoft.Insights/", "/providers/Microsoft.Insights/components/")
    app_insights_url = f"https://management.azure.com{app_insights_resource}?api-version=2015-05-01"
    app_ins_resp = requests.get(app_insights_url, headers=auth.get_authentication_header()).json()
    app_insghts_connection_string = app_ins_resp["properties"]["ConnectionString"]
    # Add APPLICATIONINSIGHTS_CONNECTION_STRING environment variable
    os.environ[aicxn] = app_insghts_connection_string

    if run_on_local:
        aml_config = ScriptRunConfig(source_directory=source_directory,
                                     script='samples/script-step/train/train.py',
                                     environment=aml_env)
    else:
        # setting aicxn does not work when running local
        # because AML add "\" to ";" in the cxn string,
        # making the cxn string invalid.
        aml_env.environment_variables[aicxn] = os.environ[aicxn]

        # Get or create AML compute resource
        if compute_name in aml_ws.compute_targets:
            aml_cluster = aml_ws.compute_targets[compute_name]
        else:
            compute_config = AmlCompute.provisioning_configuration(vm_size="Standard_DS3_v2",
                                                                vm_priority="dedicated",
                                                                min_nodes=0,
                                                                max_nodes=2,
                                                                idle_seconds_before_scaledown=600)
            aml_cluster = ComputeTarget.create(
                aml_ws, compute_name, compute_config)
            aml_cluster.wait_for_completion(show_output=True)

        aml_config = ScriptRunConfig(source_directory=source_directory,
                                     script='samples/script-step/train/train.py',
                                     environment=aml_env,
                                     compute_target=aml_cluster)
    experiment_run = aml_exp.submit(aml_config)
    print(f"{aml_exp.name} run started: {experiment_run.get_portal_url()}")


if __name__ == "__main__":
    logger.start_span("demo_span")
    try:
        main()
    except Exception as ex:
        logger.exception(ex)
    finally:
        logger.end_span()
