"""

from jinja2 import Environment, FileSystemLoader

env = Environment(loader=FileSystemLoader('.'))
template = env.get_template('db.aduri.ch.j2')

# Example data
data = {
    'zone': 'example.com',
    'host_ips': ['192.0.2.1', '192.0.2.2']
}

output = template.render(data)
print(output)


from ansible.parsing.dataloader import DataLoader
from ansible.inventory.manager import InventoryManager
from ansible.vars.manager import VariableManager

# Initialize DataLoader
loader = DataLoader()

# Initialize Inventory, and use 'hosts' file as source or another inventory file
inventory = InventoryManager(loader=loader, sources=['/path/to/your/inventory/hosts'])

# Initialize VariableManager
variable_manager = VariableManager(loader=loader, inventory=inventory)

# Specify the host to get variables for
host_name = 'localhost'

# Get host_ips variable for the specified host
host_ips = variable_manager.get_vars(host=inventory.get_host(host_name)).get('host_ips', [])

# Debug print host_ips variable
print("Debug host_ips variable:", host_ips)
"""
import json
from ansible.parsing.dataloader import DataLoader
from ansible.inventory.manager import InventoryManager
from ansible.vars.manager import VariableManager
from ansible.executor.task_queue_manager import TaskQueueManager
from ansible.plugins.callback import CallbackBase
import ansible.constants as C

from ansible.playbook.play import Play

class ResultCallback(CallbackBase):
    """A sample callback plugin used for performing actions as results come in."""
    def v2_runner_on_ok(self, result, **kwargs):
        """Prints the result of a successful execution."""
        host = result._host
        print(f"{host.name} >>> {json.dumps(result._result, indent=4)}")

# Initialize necessary objects
loader = DataLoader()  # Takes care of finding and reading yaml, json, and ini files
inventory = InventoryManager(loader=loader, sources='localhost,')  # Manages inventory
variable_manager = VariableManager(loader=loader, inventory=inventory)  # Manages variables

# Initialize the callback plugin
results_callback = ResultCallback()

# Initialize TaskQueueManager
tqm = TaskQueueManager(
          inventory=inventory,
          variable_manager=variable_manager,
          loader=loader,
          passwords={},
          stdout_callback=results_callback,  # Use our custom callback instead of the ``default`` one
      )

try:
    # Create a play with a task to gather facts then execute it
    play_source = dict(
        name="Ansible Play",
        hosts='localhost',
        gather_facts='yes',
        tasks=[
            dict(action=dict(module='setup'), register='shell_out'),
        ]
    )
    play = Play().load(play_source, variable_manager=variable_manager, loader=loader)
    
    # Actually run it
    tqm.run(play)
finally:
    tqm.cleanup()