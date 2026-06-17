// Drive the MS-DOS 6.22 install. The bootable CD lands at an A:\> prompt with
// the CD at R: (Oak IDE driver + MSCDEX, banner line "Driver BANANA"). We
// partition + format C:, copy the DOS files, write minimal boot files, then
// halt so the build seals the bootable C: disk. DOS has no guest agent, so
// every step is keyboard-driven against the live screen via OCR waits + typing.

use vmlab

fn wait_prompt(vm: Vm) -> Result[unit, string] {
    // The MSCDEX banner ("Driver BANANA unit 0") prints just before A:\>.
    vm.wait_for_text("BANANA", 180)?
    vmlab::sleep_ms(2500)
    Ok(())
}

fn install(lab: Lab) -> Result[unit, string] {
    let vm = lab.vm("build")?
    wait_prompt(vm)?

    // 1. Partition C: with fdisk: Create (1) -> Primary (1) -> max size + active (Y).
    lab.log("partitioning C: with fdisk")
    vm.type_text("fdisk\n")?;  vmlab::sleep_ms(3500)
    vm.type_text("1\n")?;      vmlab::sleep_ms(2500)   // 1 = Create DOS partition
    vm.type_text("1\n")?;      vmlab::sleep_ms(2500)   // 1 = Create Primary DOS Partition
    vm.type_text("\n")?;       vmlab::sleep_ms(3500)   // Y (max size + set active) default
    vm.type_text("\n")?;       vmlab::sleep_ms(2500)   // "press any key" -> restart

    // 2. Reboot lands back on the CD; C: is active but unformatted.
    wait_prompt(vm)?

    // 3. Format C: with system files -> bootable.
    lab.log("formatting C: /s")
    vm.type_text("format c: /s\n")?; vmlab::sleep_ms(3000)
    vm.type_text("y\n")?                                 // Proceed with Format (Y/N)?
    vm.wait_for_text("Volume label", 120)?
    vm.type_text("\n")?;       vmlab::sleep_ms(2500)     // no volume label

    // 4. Copy the DOS utilities to C:\DOS.
    lab.log("copying DOS files to C:\\DOS")
    vm.type_text("md c:\\dos\n")?; vmlab::sleep_ms(1200)
    vm.type_text("copy r:\\*.* c:\\dos\n")?
    vm.wait_for_text("copied", 120)?
    vmlab::sleep_ms(2000)

    // 5. Minimal boot files in C:\ root.
    vm.type_text("echo PATH C:\\DOS> c:\\autoexec.bat\n")?;  vmlab::sleep_ms(600)
    vm.type_text("echo PROMPT $P$G>> c:\\autoexec.bat\n")?;  vmlab::sleep_ms(600)
    vm.type_text("echo FILES=30> c:\\config.sys\n")?;        vmlab::sleep_ms(600)
    vm.type_text("echo BUFFERS=20>> c:\\config.sys\n")?;     vmlab::sleep_ms(1500)

    // DOS has no ACPI, so the build's graceful stop can't power it off — halt
    // from idle ourselves (no writes are in flight at A:\>, so the qcow2 is
    // consistent).
    lab.log("MS-DOS 6.22 installed to C:; halting to seal")
    vmlab::sleep_ms(3000)
    vm.stop_force()?
    Ok(())
}

fn main(lab: Lab) {
    install(lab).expect("dos-6.22 build failed")
}
