// Build provision for the windows-server-2025 template (PRD §6.1, §10.4).
// Two human moments to automate: the ISO's "Press any key to boot from CD
// or DVD" prompt right after power-on, and knowing when the unattended
// install is done — autounattend.xml installs the QEMU guest agent as its
// last first-logon command, so "agent responding" means finished.
//
// The image is then generalized: sysprep /generalize /oobe /shutdown with
// unattend/sysprep-unattend.xml, so every clone gets a fresh SID and a
// random computer name and can join a domain. Sysprep powers the VM off
// and the build seals the generalized disk.

use vmlab

fn boot_from_dvd(lab: Lab, vm: Vm) -> Result[unit, string] {
    for attempt in 0..4 {
        // Spam enter through the prompt's window.
        for i in 0..30 {
            let k = vm.send_keys("enter")   // bind unused Result
            vmlab::sleep_ms(1000)
        }
        // If we missed it, OVMF falls through to its shell; reset and retry.
        let screen = vm.ocr()?
        if screen.contains("Shell>") || screen.contains("UEFI Interactive Shell") {
            lab.log(fmt("missed the boot prompt (attempt {}), resetting", attempt))
            vm.restart()?
            vmlab::sleep_ms(3000)
        } else {
            return Ok(())
        }
    }
    Err("never got past the press-any-key prompt")
}

fn install(lab: Lab) -> Result[unit, string] {
    let vm = lab.vm("build")?
    boot_from_dvd(lab, vm)?

    lab.log("Windows Setup running; unattended install takes 20-40 minutes...")
    vm.wait_ready(5400)?

    match vm.exec("cmd.exe", ["/c", "ver"]) {
        Ok(r)  => lab.log("installed: " + r.stdout.trim()),
        Err(e) => lab.log("version check failed (agent is up though): " + e),
    }

    sysprep(lab, vm)
}

// Generalize the image so clones get fresh SIDs (domain-joinable). The
// answer file rides the UNATTEND ISO; copy it onto the disk first since
// the ISO is not attached to lab clones.
fn sysprep(lab: Lab, vm: Vm) -> Result[unit, string] {
    let copy = vm.exec("cmd.exe", [
        "/c",
        "for %d in (D E F G) do if exist %d:\\sysprep-unattend.xml copy /y %d:\\sysprep-unattend.xml C:\\Windows\\Temp\\sysprep-unattend.xml",
    ])?
    if copy.exit_code != 0 {
        return Err("could not stage sysprep-unattend.xml: " + copy.stderr)
    }

    lab.log("running sysprep /generalize (5-10 minutes, powers the VM off)...")
    // Fire-and-forget via start: sysprep shuts the guest down, which kills
    // the agent connection mid-exec — an Err here is expected noise.
    match vm.exec_timeout("cmd.exe", [
        "/c",
        "start C:\\Windows\\System32\\Sysprep\\sysprep.exe /generalize /oobe /shutdown /quiet /unattend:C:\\Windows\\Temp\\sysprep-unattend.xml",
    ], 60) {
        Ok(_)  => lab.log("sysprep launched"),
        Err(e) => lab.log("sysprep launch returned an error (often benign): " + e),
    }

    vm.wait_shutdown(1800)?
    lab.log("sysprep finished; sealing the generalized image")
    Ok(())
}

fn main(lab: Lab) {
    install(lab).expect("windows-server-2025 build failed")
}
