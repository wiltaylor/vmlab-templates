// EXPLORE STUB — boots the VM, types past any "boot from CD" prompt, then
// holds the VM up so the installer screen can be inspected via the VNC socket
// and the real automation written. Replace with the driven install once the
// installer flow is known.
use vmlab

fn main(lab: Lab) {
    let vm = lab.vm("build").expect("no build vm")
    for i in 0..20 { let k = vm.send_keys("ret"); vmlab::sleep_ms(500) }
    lab.log("EXPLORE: VM up; inspect via VNC, then write the install automation")
    vm.wait_shutdown(3600).expect("explore hold ended")
}
