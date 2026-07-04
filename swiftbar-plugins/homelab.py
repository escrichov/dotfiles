#!/usr/bin/env python3
# <xbar.title>Homelab</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Carlos</xbar.author>
# <xbar.author.github>escrichov</xbar.author.github>
# <xbar.desc>Homelab actions</xbar.desc>
# <xbar.image></xbar.image>
# <xbar.dependencies></xbar.dependencies>
# <xbar.abouturl></xbar.abouturl>
# <xbar.droptypes></xbar.droptypes>
# <swiftbar.type>streamable</swiftbar.type>
import os
import subprocess
import sys
import socket
import time
from contextlib import closing
from typing import List


SCRIPT_PATH = os.path.realpath(__file__)
TERMINAL_NOTIFIER_PATH = "/opt/homebrew/bin/terminal-notifier"
WAKE_ON_LAN_PATH = "/opt/homebrew/bin/wakeonlan"

SERVER_TYPE_NONE = "none"
SERVER_TYPE_WINDOWS = "windows"
SERVER_TYPE_LINUX = "linux"
WINDOWS_ICON = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAA0dJREFUeNrt2UtIFVEcx/GZS74raFeEtGhhLSKIKHshZZmZBO1qFaGoEGkUIlGL1oFUPopCeq/aaSm91SLatkgRM7IHZaSW7+t1Zv59C4VhHAev3Ot9nR98PHeh3Ht+c84ZvKOpqKjEZTKaBpKxCjuRj9R4n+xKbMNx1KIZnRhDNzLj7cpuRxHq0Iz3GIYBcfiBdVosZWnToM6HTsFq7EAJ6tGCTozAhMzDL2yM3qs6PVlkYhfKcA2P0YVRmJAFGsSm6Jhs4//JpmINcnAS1/EE3RiDCQmh39isRSLpjf26bf8moQov0WOfbJj9wZYwL+N+H2+ShrXIxRnUYb2tgDS0QRbZELaGbrIPB/5NNh1Z2Icq3EYrejEBCwEUxnQB/KEPGchCHs7iLtrxFX5YEBcmjsZKAc5JZ+M87uEVvrlO1puFY1FSQHYwBaTiGSQEiqOggOF5FRCmD1oWzQX4EO7oiGC8P8cSJExUAaoAVYAqQBWgClAFqAJUAaoAVUDICxBY00wINOKDAXumYIDRNaaN5UJcRsJr9+gYhT+YAqZwCQ8g8IoBPybhx7htcjq6MZMAzmEZDLjFsJUEinAvRXRoAD908b5AMqAeGKrMjs5TGc0lSSyZI4yZCMBwLE2nKcfeFsykCz9tZ8IGrIB4ngHenNvDSWCPIADL5QyQuc6GIuTALeLBcvxeKe5DIym4iN0eZ4D9gDMdr61ppr18xxhwKWAclegI1V1AB+aVZNiTgiRg0TKC5ZgVHxImqoAIFSCJXIAAib0CLLUF1BZQK0CdAQm7BdQhqFaAWgHRUoAEU4DATOQVEMAFVOAO3qIPgRhdARJsARZeowZFyMNeHMYJNOANvmPS4w0kFreAMyZG0YEWXEUp9iMXh1CGerTjC/yQeL4LWBhDF57ihqbp5YwFyEUhSnAFfYlyF7Awjh68QIMuUoV3jucNj9COz/BDEO4IEPl/hgxd06oZDzhWSg3awliKwIqWr8QEE/g4s1JwCgXwLCXyBUS+lNoFlmLCCEEBES5FtApHKcW4jFZ8wsQcpRiYDH0BkS/lpi5ymvEg9kyPRajGc3yAH0MYjf0CvEvpRStuabpUMhYiF/koR796EqqiMit/AcePPcIiWnWCAAAAAElFTkSuQmCC"
LINUX_ICON = "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"


def check_port_open(ip, port, timeout_seconds=0.5):
    socket.setdefaulttimeout(timeout_seconds)
    with closing(socket.socket(socket.AF_INET, socket.SOCK_STREAM)) as sock:
        error = sock.connect_ex((ip, port))
        if error == 0:
            return True
        else:
            return False


class Server:
    title = "Server"
    commands = []
    server_type = SERVER_TYPE_NONE
    mac_address = ""
    broadcast_ip = ""
    ip = ""
    port = 0
    wake_on_lan = True
    grub_selection = None
    parent_server = None
    ssh_destination = None

    def is_active(self):
        return check_port_open(self.ip, self.port)

    def __init__(self, parent_server=None):
        if parent_server:
            self.parent_server = parent_server


class Command:
    title = ""
    terminal = False

    def run(self):
        raise NotImplementedError()

    def execute(self):
        exit_code = self.run()
        return exit_code

    @property
    def name(self):
        return str(type(self).__name__)

    def subprocess_run(self, *args, notify_error=True, notify_ok=False, **kwargs):
        if not 'capture_output' in kwargs:
            kwargs["capture_output"] = True

        try:
            result = subprocess.run(*args, **kwargs)
            if result.returncode == 0 and notify_ok:
                message = "Ok"
                push_notify(title=self.title, message=message)
            elif result.returncode != 0 and notify_error:
                message = "Failed: \n"
                if result.stdout:
                    message += result.stdout.decode("utf-8") + "\n"
                if result.stderr:
                    message += result.stderr.decode("utf-8") + "\n"
                push_notify(title=self.title, message=message)
            return_code = result.returncode
        except FileNotFoundError as e:
            return_code = None
            if notify_error:
                push_notify(title=self.title, message=f"Exception: {e}")

        return return_code

    def __str__(self):
        return f"{self.title} | bash={SCRIPT_PATH} param1={self.name} terminal={self.terminal}"


class OpenUrlCommand(Command):
    url = ""

    def get_url(self):
        return self.url

    @property
    def name(self):
        return f'{super().name}-{self.url}'

    def run(self):
        return self.subprocess_run(args=["open", self.get_url()])


class OpenAppCommand(Command):
    app_name = ""

    @property
    def name(self):
        return f'{super().name}-{self.app_name.replace(" ", "_")}'

    def run(self):
        return self.subprocess_run(args=["open", "-a", self.app_name])


class SSHCommand(Command):
    command = None
    notify_ok = False
    notify_error = True

    def __init__(self, ssh_destination):
        super().__init__()
        self.ssh_destination = ssh_destination

    def get_command(self):
        return self.command

    def run(self):
        return self.subprocess_run(
            args=["ssh", self.ssh_destination, self.get_command()],
            notify_ok=self.notify_ok,
            notify_error=self.notify_error
        )


######### HOME COMMANDS #######

class WakeOnLanCommand(Command):
    title = "Wake on lan"
    mac_address = ""
    broadcast_ip = ""

    def __init__(self, server: Server):
        self.server = server
        self.title = f"Wake {server.title}"
        self.mac_address = server.mac_address
        self.broadcast_ip = server.broadcast_ip

    def run(self):
        return self.subprocess_run(args=[WAKE_ON_LAN_PATH, "-i", self.broadcast_ip, "-p", "1234", self.mac_address])

    @property
    def name(self):
        return f'{super().name}-{self.broadcast_ip}-{self.mac_address}'


class GrubSelectCommand(SSHCommand):
    title = "Grub Select"

    def get_command(self):
        return f"sudo grub-reboot {self.grub_selection}; sudo reboot"

    def __init__(self, ssh_destination, grub_selection):
        super().__init__(ssh_destination)
        self.grub_selection = grub_selection
        self.notify_ok = True


class WakeOnLanAndGrubSelectCommand(WakeOnLanCommand):
    initial_sleep = 30
    timeout_seconds = 90

    def __init__(self, server: Server):
        super().__init__(server.parent_server)
        self.ssh_destination = server.parent_server.ssh_destination
        self.grub_selection = server.grub_selection
        self.title = f"Wake {server.title}"

    def wait_for_server(self):
        time.sleep(self.initial_sleep)
        seconds = self.initial_sleep

        is_active = self.server.is_active()
        while not is_active and seconds < self.timeout_seconds:
            time.sleep(1)
            seconds += 1
            is_active = self.server.is_active()

        return is_active

    def run(self):
        result_code = super().run()
        if result_code != 0:
            return result_code

        is_active = self.wait_for_server()
        if not is_active:
            push_notify(title=self.title, message=f"Failed\nTimeout in {self.timeout_seconds} seconds")
            return 1

        return GrubSelectCommand(self.ssh_destination, self.grub_selection).run()


######### WINDOWS COMMANDS #######

class WindowsShutdownCommand(SSHCommand):
    title = "Shutdown"

    def get_command(self):
        return "shutdown /s /t 0"


class WindowsRemoteDesktopCommand(OpenAppCommand):
    title = "Remote Desktop"
    app_name = "Windows App"


######### LINUX COMMANDS #######

class LinuxUpdateCommand(SSHCommand):
    title = "Update"
    terminal = True

    def run(self):
        return self.subprocess_run(
            args=["ssh", "-t", self.ssh_destination, "/bin/bash", "-ic", "update"],
            capture_output=False,
            notify_error=False
        )


class RebootToWindowsCommand(GrubSelectCommand):
    title = "Reboot to Windows"


class LinuxShutdownCommand(SSHCommand):
    title = "Shutdown"
    notify_ok = True

    def get_command(self):
        return "sudo poweroff"


class LinuxRemoteDesktopCommand(OpenAppCommand):
    title = "Remote Desktop"
    app_name = "Remote Desktop Manager"


class OpenGrafanaCommand(OpenUrlCommand):
    title = "Grafana"
    ip = ""

    def __init__(self, ip: str):
        self.ip = ip

    def get_url(self):
        return f"http://{self.ip}:3000/"


class OpenOverseerrCommand(OpenUrlCommand):
    title = "Overseerr"
    ip = ""

    def __init__(self, ip: str):
        self.ip = ip

    def get_url(self):
        return f"http://{self.ip}:5055/"


class OpenTransmissionCommand(OpenUrlCommand):
    title = "Transmission"
    ip = ""

    def __init__(self, ip: str):
        self.ip = ip

    def get_url(self):
        return f"http://{self.ip}:9091/"


def push_notify(title, message):
    subprocess.run([TERMINAL_NOTIFIER_PATH, "-message", message, "-title", title])


def print_menu(server: Server):
    server_type = server.server_type
    if server.server_type == SERVER_TYPE_NONE or not server_type:
        print(" | sfimage=desktopcomputer")
    else:
        icon = WINDOWS_ICON if server_type == SERVER_TYPE_WINDOWS else LINUX_ICON
        print(f" | image={icon} width=20 height=20")
    print("---")
    print(server.title)
    print("---")

    for cmd in server.commands:
        print(cmd)


class CommandRegistry:
    registry = {}

    def register(self, commands: List[Command]):
        for command in commands:
            self.registry[command.name] = command

    def get_command(self, name: str) -> Command:
        return self.registry.get(name)


class PamplonaWindowsServer(Server):
    title = "Pamplona Windows"
    ip = "192.168.1.13"
    broadcast_ip = "192.168.1.255"
    mac_address = "30:9C:23:01:7E:4F"
    port = 135
    server_type = SERVER_TYPE_WINDOWS
    grub_selection = 2
    ssh_destination = "homelabwin"
    commands = [
        WindowsRemoteDesktopCommand(),
        WindowsShutdownCommand(ssh_destination),
    ]


class PamplonaLinuxServer(Server):
    title = "Pamplona Linux"
    ip = "192.168.1.13"
    broadcast_ip = "192.168.1.255"
    mac_address = "30:9C:23:01:7E:4F"
    port = 22  # SSH: Overseerr (5055) ya no corre; el 22 indica de forma fiable que Linux está arrancado
    server_type = SERVER_TYPE_LINUX
    ssh_destination = "homelab"
    commands = [
        LinuxRemoteDesktopCommand(),
        RebootToWindowsCommand(ssh_destination=ssh_destination, grub_selection=PamplonaWindowsServer.grub_selection),
        LinuxUpdateCommand(ssh_destination=ssh_destination),
        LinuxShutdownCommand(ssh_destination=ssh_destination),
    ]


class SarrionWindowsServer(Server):
    title = "Sarrion Windows"
    ip = "10.0.0.10"
    broadcast_ip = "10.0.0.255"
    mac_address = "70:8B:CD:4E:17:9A"
    port = 135
    server_type = SERVER_TYPE_WINDOWS
    commands = [
        WindowsRemoteDesktopCommand(),
    ]


def create_servers():
    pamplona_linux_server = PamplonaLinuxServer()
    # Windows va primero: comparte IP con Linux y ambos abren el 22 (SSH), pero solo
    # Windows abre el 135 (RPC). Comprobando Windows antes desempatamos correctamente.
    servers = [
        PamplonaWindowsServer(pamplona_linux_server),
        pamplona_linux_server,
        SarrionWindowsServer(),
    ]

    class NoServer(Server):
        title = "No Server"
        server_type = SERVER_TYPE_NONE
        commands = []
        for server in servers:
            if server.wake_on_lan:
                if server.parent_server:
                    commands.append(WakeOnLanAndGrubSelectCommand(server))
                else:
                    commands.append(WakeOnLanCommand(server))

        def is_active(self):
            return True

    servers.append(NoServer())

    return servers


def run_streamable(servers: List[Server], interval_seconds: int):
    current_server = None
    while True:
        for server in servers:
            if server.is_active():
                if current_server != server:
                    print("~~~")
                    print_menu(server)
                    sys.stdout.flush()
                    current_server = server
                break

        time.sleep(interval_seconds)


def run_normal(servers: List[Server]):
    for server in servers:
        if server.is_active():
            print_menu(server)
            sys.exit(0)


if __name__ == "__main__":
    servers = create_servers()
    registry = CommandRegistry()
    for server in servers:
        registry.register(server.commands)

    if len(sys.argv) > 1:
        param = sys.argv[1]
        cmd = registry.get_command(param)
        if cmd:
            exit_code = cmd.execute()
            sys.exit(exit_code)
        else:
            print("Command not found")
            sys.exit(1)
    else:
        run_streamable(servers, 5)
