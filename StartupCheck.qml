import QtQuick
import qs.Common
import Quickshell.Io

QtObject {
    function check(done) {
        var deps = [
            { bin: "awww", name: "awww (wallpaper daemon)" },
            { bin: "matugen", name: "Matugen (color theming)" },
            { bin: "ffmpeg", name: "ffmpeg (thumbnail extraction)" }
        ]
        var missing = []
        var total = deps.length + 1
        var checked = 0

        function verifyMagick() {
            Proc.runCommand("wallsync.depCheck.magick", ["which", "magick"], (stdout, exitCode) => {
                checked++
                if (exitCode !== 0) {
                    Proc.runCommand("wallsync.depCheck.convert", ["which", "convert"], (stdout2, exitCode2) => {
                        checked++
                        if (exitCode2 !== 0) {
                            missing.push("ImageMagick (magick or convert)")
                        }
                        finishCheck()
                    })
                } else {
                    checked++
                    finishCheck()
                }
            })
        }

        function checkDep(index) {
            if (index >= deps.length) {
                verifyMagick()
                return
            }
            var dep = deps[index]
            Proc.runCommand("wallsync.depCheck." + dep.bin, ["which", dep.bin], (stdout, exitCode) => {
                checked++
                if (exitCode !== 0) missing.push(dep.name)
                checkDep(index + 1)
            })
        }

        function finishCheck() {
            if (missing.length > 0) {
                done({
                    title: "Missing dependencies",
                    details: "Install the following:\n\n" + missing.join("\n") + "\n\nSee https://github.com/Zhainy/wallsync-dms#dependencies"
                })
            } else {
                done(null)
            }
        }

        checkDep(0)
    }
}
