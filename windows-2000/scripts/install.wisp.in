// Install Windows 2000 Professional SP4, mostly unattended via A:\winnt.sif.
//
// The bootable CD's Setup auto-reads the answer floppy (A:\winnt.sif) for the
// EULA, admin password, auto-logon and the GUI phase. Three things still need
// keystrokes:
//   1. the one-time "Press any key to boot from CD" prompt (first boot only),
//   2. the text-mode partition/format screens (AutoPartition won't pick a blank
//      disk), and
//   3. the product key: on this retail media the GUI phase ignores the
//      winnt.sif ProductKey (a known Win2000 FullUnattended bug) and pops a
//      "missing parameter" dialog, so we dismiss it and type the key.
//
// The catch: with the CD ahead of the disk in the boot order, any key pressed
// during an install reboot re-triggers the boot-CD prompt and restarts Setup.
// So we must press ONLY when the key dialog is actually on screen. Its hatched
// teal background defeats OCR, so we detect it by IMAGE (the red error icon +
// text, scripts/ref/key-error.png) instead. The reboots in between are silent.
// The desktop ("Getting Started") OCRs fine on its solid background.
//
// We seal with a clean ACPI shutdown (Win2000 installs an ACPI HAL on the
// emulated i440fx, so it flushes NTFS). No guest agent.

use vmlab

// Press a key and confirm `expect` appears, retrying if it didn't land.
fn key_until(vm: Vm, chord: string, expect: string, timeout: int) -> Result[unit, string] {
    for attempt in 0..6 {
        vm.send_keys(chord)?
        match vm.wait_for_text(expect, timeout) {
            Ok(_)  => return Ok(()),
            Err(_) => vmlab::sleep_ms(800),
        }
    }
    Err("never reached screen: " + expect)
}

fn install(lab: Lab) -> Result[unit, string] {
    let vm = lab.vm("build")?

    // The Windows 2000 product key, typed into the GUI key page (5
    // auto-advancing boxes, so no dashes). In sync with WINDOWS_2000_PRO_KEY.
    let product_key = "__PRODUCT_KEY__"

    // Catch the brief (~5s) "Press any key to boot from CD" window. Text Setup
    // ignores stray keys, so spamming Enter for the first ~12s is safe.
    lab.log("nudging the boot-CD prompt")
    for i in 0..9 {
        vm.send_keys("enter")?
        vmlab::sleep_ms(1300)
    }

    // Text-mode Setup partition screen: install onto the unpartitioned space
    // (Enter creates a partition using the whole disk), then format NTFS (the
    // default-highlighted choice).
    lab.log("driving the partition + format screens")
    vm.wait_for_text("Unpartitioned space", 300)?
    key_until(vm, "enter", "Format the partition", 60)?
    vm.send_keys("enter")?

    // Format -> copy -> reboot into graphical Setup, which pops the product-key
    // dialog. Wait for it by image (the dialog is modal and persistent, so
    // there is no timing pressure), then dismiss it and type the key. No keys
    // are pressed until it appears, so the intervening reboot is left alone.
    lab.log("waiting for the GUI product-key dialog (image match)")
    vm.wait_for_image("ref/key-error.png", 3000)?
    vm.send_keys("enter")?            // dismiss "missing parameter" -> key page
    vmlab::sleep_ms(2500)
    lab.log("entering the product key")
    vm.type_text(product_key)?        // first box auto-focused; boxes auto-advance
    vmlab::sleep_ms(2000)
    vm.send_keys("enter")?            // submit / Next

    // Graphical Setup now runs unattended, reboots, and auto-logs on. Press
    // nothing (so the reboot's boot-CD prompt is ignored); just watch for the
    // desktop, which OCR can read.
    lab.log("waiting for the desktop (auto-logon)")
    vm.wait_for_text("Getting Started", 2400)?
    vmlab::sleep_ms(20000)
    let d = vm.screenshot("")?
    lab.log("desktop reached: " + d)

    // Seal: ACPI shutdown so Win2000 flushes NTFS, then wait for power-off.
    lab.log("Windows 2000 installed; shutting down to seal")
    vm.stop()?
    vm.wait_shutdown(300)?
    Ok(())
}

fn main(lab: Lab) {
    install(lab).expect("windows-2000 build failed")
}
