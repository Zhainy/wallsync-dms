import QtQuick
import qs.Common

QtObject {
    id: root

    function check(done) {
        const deps = ["awww", "matugen", "magick", "ffmpeg", "python3"]
        const missing = []
        let checked = 0

        for (let i = 0; i < deps.length; i++) {
            const depName = deps[i]
            Proc.runCommand("wallsync.depCheck." + depName, ["which", depName], function(stdout, exitCode) {
                checked++
                if (exitCode !== 0) {
                    // Magick fallback check to legacy convert
                    if (this.depName === "magick") {
                        Proc.runCommand("wallsync.depCheck.convert", ["which", "convert"], function(stdout2, exitCode2) {
                            if (exitCode2 !== 0) {
                                missing.push("imagemagick (magick/convert)")
                            }
                            finalizeCheck()
                        })
                        return
                    }
                    missing.push(this.depName)
                }
                finalizeCheck()
            }.bind({ depName: depName }))
        }

        function finalizeCheck() {
            if (checked === deps.length) {
                if (missing.length > 0) {
                    done({
                        title: "Wallsync: Missing Dependencies",
                        details: "The following binaries are required but missing from PATH: " + missing.join(", ")
                    })
                } else {
                    done(null) // No errors
                }
            }
        }
    }
}
