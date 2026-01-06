pragma Singleton
pragma ComponentBehavior: Bound
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

/**
 * Screensharing and mic activity.
 */
Singleton {
    id: root

    function videoLinkProps(pwlg) {
        const srcProps = pwlg?.source?.properties ?? ({})
        const tgtProps = pwlg?.target?.properties ?? ({})
        const role = (srcProps["media.role"] || tgtProps["media.role"] || "").toLowerCase()
        const desc = (srcProps["node.description"] || srcProps["device.description"] || pwlg?.source?.name || "").toLowerCase()
        const appName = (tgtProps["application.name"] || tgtProps["node.description"] || "").toLowerCase()
        const srcClass = (srcProps["media.class"] || "").toLowerCase()
        const tgtClass = (tgtProps["media.class"] || "").toLowerCase()
        const srcType = pwlg?.source?.type
        const tgtType = pwlg?.target?.type
        const srcName = (pwlg?.source?.name || "").toLowerCase()
        const tgtName = (pwlg?.target?.name || "").toLowerCase()
        return { role, desc, appName, srcClass, tgtClass, srcType, tgtType, srcName, tgtName }
    }

    function looksLikeVideo(props) {
        return props.srcClass.includes("video") || props.tgtClass.includes("video") || props.srcType === PwNodeType.VideoSource || props.tgtType === PwNodeType.VideoInStream
    }

    function looksLikeScreen(props) {
        return props.desc.includes("screen") || props.desc.includes("desktop") || props.appName.includes("portal") || props.appName.includes("screen") || props.appName.includes("cast") || props.srcClass.includes("stream") || props.tgtClass.includes("stream") || props.tgtClass.includes("session") || props.srcClass.includes("session")
    }

    function looksLikeCamera(props) {
        const nameHit = props.srcName.includes("v4l2_input") || props.tgtName.includes("v4l2_input")
        const nickHit = props.desc.includes("webcam") || props.desc.includes("camera") || props.desc.includes("integrated_webcam_fhd")
        return nameHit || nickHit || props.role.includes("camera") || props.desc.includes("uvc") || props.srcClass.includes("video/source") || props.srcClass.includes("source/video")
    }

    property bool screenSharing: Pipewire.linkGroups.values.some(pwlg => {
        const props = videoLinkProps(pwlg)
        const typeHit = (props.srcType === PwNodeType.VideoSource) || (props.tgtType === PwNodeType.VideoInStream)
        const videoish = looksLikeVideo(props) || typeHit
        if (!videoish) return false
        const screen = looksLikeScreen(props)
        const cam = looksLikeCamera(props)
        return (typeHit && !cam) || (screen && !cam)
    })
    property bool micActive: Pipewire.linkGroups.values.some(pwlg => pwlg.source.type === PwNodeType.AudioSource && pwlg.target.type === PwNodeType.AudioInStream)
    property bool cameraActive: Pipewire.linkGroups.values.some(pwlg => {
        const props = videoLinkProps(pwlg)
        const typeHit = (props.srcType === PwNodeType.VideoSource) || (props.tgtType === PwNodeType.VideoInStream)
        const videoish = looksLikeVideo(props) || typeHit
        if (!videoish) return false
        const screen = looksLikeScreen(props)
        const cam = looksLikeCamera(props)
        if (cam && !screen) return true
        // If it's video but not classified as screenSharing, consider it camera
        return !screenSharing
    })

}
