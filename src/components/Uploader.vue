<template>
  <div class="uploader-container">
    <h2>*notices ur bulge*</h2>
    <hr />
    <p>yiff.wtf is a hosting service for image and video media</p>
    <p>[*] individual upload size is limited to 100 MB</p>
    <hr />

    <p style="color: red">
      [!] read the <a href="/faq" style="text-decoration: none">[faq]</a> and
      <a href="/dmca" style="text-decoration: none">[dmca notice]</a> before
      uploading
    </p>
    <hr />

    <div class="controls">
      <input
        id="file-picker"
        class="hidden"
        type="file"
        accept="image/*,video/*,text/*"
        @change="onFileSelected"
      />
      <label for="file-picker" class="btn-choose">choose file</label>

      <button class="btn-upload" v-if="file && !uploaded" @click="startUpload">
        {{ uploading ? "uploading…" : "upload" }}
      </button>
    </div>

    <div class="meta" v-if="file">
      <h3>{{ file.name }}</h3>
      <div class="meta-row">
        <span class="muted">{{ prettySize(file.size) }}</span>
        <span class="muted">• {{ file.type || "unknown" }}</span>
        <span class="muted">• {{ Math.round(sizePercent) }}% of 100 MB</span>
      </div>

      <div class="preview">
        <div
          v-if="isImage"
          class="preview-thumb"
          @click="openOverlay"
          role="button"
          tabindex="0"
        >
          <img :src="preview" alt="preview" class="preview-img" />
        </div>

        <div
          v-else-if="isVideo"
          class="preview-thumb"
          @click="openOverlay"
          role="button"
          tabindex="0"
        >
          <video
            :src="preview"
            class="preview-video-small"
            muted
            playsinline
          ></video>
        </div>

        <pre v-else-if="isText" class="preview-text">{{ previewText }}</pre>
        <div v-else class="muted">no preview available</div>
      </div>

      <div
        v-if="overlayVisible"
        class="overlay"
        @click="onOverlayBackgroundClick"
      >
        <div class="overlay-content" @click.stop>
          <img
            v-if="isImage"
            :src="preview"
            alt="preview"
            class="overlay-media overlay-image"
          />
          <video
            v-else-if="isVideo"
            :src="preview"
            controls
            class="overlay-media overlay-video"
          ></video>

          <div class="overlay-actions">
            <button
              class="btn-upload"
              :disabled="!file || uploading"
              @click.stop="startUpload"
            >
              {{ uploading ? "uploading…" : "upload" }}
            </button>
            <button
              class="btn-cancel"
              :disabled="uploading"
              @click.stop="clearFile"
            >
              cancel
            </button>
          </div>
        </div>
      </div>

      <div class="meta-actions" v-if="file">
        <button class="btn-remove" :disabled="uploading" @click="clearFile">
          remove
        </button>
      </div>
    </div>

    <div class="progress" v-if="uploading">
      <div class="progress-bar" :style="{ width: progressPercent + '%' }"></div>
      <div class="muted">{{ Math.round(progressPercent) }}% uploaded</div>
    </div>

    <div class="result" v-if="url">
      <input ref="resultUrl" class="result-input" :value="url" readonly />
      <button class="btn-copy" @click="copyUrl">copy</button>
    </div>

    <div class="error" v-if="error" role="alert">
      {{ error }}
      <div>
        <button
          v-if="file && !uploading"
          class="btn-retry"
          @click="startUpload"
        >
          retry
        </button>
      </div>
    </div>

    <div class="footer">
      <p>
        <a href="/canary.json" style="text-decoration: none; color: #d32f2f"
          >[canary]</a
        >
        -
        <a
          href="https://status.yiff.wtf"
          style="text-decoration: none; color: #1e8449"
          >[status]</a
        >
        -
        <a
          href="https://github.com/YIFFDOTWTF"
          style="text-decoration: none; color: #1e8449"
          >[source]</a
        >
        -
        <a
          :href="`https://github.com/YIFFDOTWTF/frontend/commit/${fullHash}`"
          style="text-decoration: none; color: #1e8449"
          >[{{ commitHash }} - {{ commitDate }}]</a
        >
      </p>
    </div>
  </div>
</template>

<script>
const MAX_BYTES = 100 * 1024 * 1024;

export default {
  name: "Uploader",
  data() {
    return {
      file: null,
      preview: "",
      previewText: "",
      url: "",
      overlayVisible: false,
      uploading: false,
      progressPercent: 0,
      error: "",
      fullHash: typeof COMMIT_HASH_FULL !== "undefined" ? COMMIT_HASH_FULL : "",
      commitHash: typeof COMMIT_HASH !== "undefined" ? COMMIT_HASH : "",
      commitDate:
        typeof COMMIT_DATE !== "undefined"
          ? new Date(+COMMIT_DATE * 1000).toLocaleDateString()
          : "",
    };
  },
  computed: {
    isImage() {
      return this.file && this.file.type && this.file.type.startsWith("image/");
    },
    isVideo() {
      return this.file && this.file.type && this.file.type.startsWith("video/");
    },
    isText() {
      return this.file && this.file.type && this.file.type.startsWith("text/");
    },
    sizePercent() {
      if (!this.file) return 0;
      return (this.file.size / MAX_BYTES) * 100;
    },
  },
  methods: {
    prettySize(bytes) {
      if (bytes == null || isNaN(bytes)) return "";
      const thresh = 1024;
      if (Math.abs(bytes) < thresh) return bytes + " B";
      const units = ["KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
      let u = -1;
      do {
        bytes /= thresh;
        ++u;
      } while (Math.abs(bytes) >= thresh && u < units.length - 1);
      const precision = Math.abs(bytes) < 10 ? 1 : 0;
      return bytes.toFixed(precision) + " " + units[u];
    },

    onFileSelected(ev) {
      const f = ev && ev.target && ev.target.files && ev.target.files[0];
      if (f) this.prepareFile(f);
      if (ev && ev.target) ev.target.value = "";
    },
    prepareFile(file) {
      this.clearError();
      if (!file) return;
      if (file.size > MAX_BYTES) {
        this.error =
          "that's way too big, even for me owo~. size limit is 100 MB";
        this.file = null;
        return;
      }
      this.file = file;
      this.url = "";
      this.progressPercent = 0;
      this.readPreview(file);

      if (
        file.type &&
        (file.type.startsWith("image/") || file.type.startsWith("video/"))
      ) {
        this.overlayVisible = true;
      }
    },
    readPreview(file) {
      this.preview = "";
      this.previewText = "";
      try {
        if (file.type && file.type.startsWith("image/")) {
          const reader = new FileReader();
          reader.onload = (e) => {
            this.preview = e.target.result;
          };
          reader.readAsDataURL(file);
        } else if (file.type && file.type.startsWith("video/")) {
          this.preview = URL.createObjectURL(file);
        } else if (
          (file.type && file.type.startsWith("text/")) ||
          (file.name &&
            (file.name.endsWith(".txt") || file.name.endsWith(".json")))
        ) {
          const reader = new FileReader();
          reader.onload = (e) => {
            this.previewText = e.target.result.slice(0, 20000);
          };
          reader.readAsText(file);
        }
      } catch (err) {
        this.preview = "";
      }
    },
    openOverlay() {
      this.overlayVisible = true;
    },
    closeOverlay() {
      this.overlayVisible = false;
    },
    onOverlayBackgroundClick(ev) {
      this.closeOverlay();
    },
    startUpload() {
      if (this.overlayVisible) {
        this.closeOverlay();
      }
      if (!this.file) {
        this.error = "choose a file first";
        return;
      }
      if (this.file.size > MAX_BYTES) {
        this.error = "file exceeds 30 MB limit";
        return;
      }
      this.upload();
    },
    upload() {
      const toSend = this.file;
      const endpoint = "https://i.yiff.wtf/upload?password=lul";
      const form = new FormData();
      form.append("file", toSend);
      const xhr = new XMLHttpRequest();
      xhr.open("POST", endpoint, true);
      this.uploading = true;
      this.progressPercent = 0;
      xhr.upload.onprogress = (e) => {
        if (e.lengthComputable)
          this.progressPercent = (e.loaded / e.total) * 100;
      };
      xhr.onload = () => {
        this.uploading = false;
        this.progressPercent = 100;
        if (xhr.status >= 200 && xhr.status < 300) {
          this.url = xhr.responseText || "";
          if (!this.url) {
            this.error = "upload succeeded but no url returned";
          }
        } else if (xhr.status >= 400 && xhr.status < 500) {
          this.error = "upload rejected by server";
        } else {
          this.error = "server error during upload";
        }
      };
      xhr.onerror = () => {
        this.uploading = false;
        this.error = "network error during upload";
      };
      xhr.send(form);
    },
    copyUrl() {
      if (!this.url) return;
      try {
        if (navigator && navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(this.url);
        } else {
          const el = this.$refs.resultUrl;
          if (el && el.select) {
            el.select();
            document.execCommand("copy");
          }
        }
      } catch (err) {
        // swallowed
      }
    },
    clearFile() {
      if (this.uploading) return;
      this.file = null;
      this.overlayVisible = false;
      if (
        this.preview &&
        typeof this.preview === "string" &&
        this.preview.startsWith("blob:")
      ) {
        try {
          URL.revokeObjectURL(this.preview);
        } catch (e) {}
      }
      this.preview = "";
      this.previewText = "";
      this.url = "";
      this.progressPercent = 0;
      this.clearError();
    },
    clearError() {
      this.error = "";
    },
    pasteHandler(ev) {
      try {
        const data = ev && ev.clipboardData;
        if (!data) return;
        if (data.files && data.files.length) {
          this.prepareFile(data.files[0]);
          return;
        }
        const text = data.getData("text");
        if (text) {
          const blob = new Blob([text], { type: "text/plain" });
          blob.name = "pasted.txt";
          this.prepareFile(blob);
        }
      } catch (err) {
        // swallowed
      }
    },
    onDrop(ev) {
      ev.preventDefault();
      ev.stopPropagation();
      const f =
        ev &&
        ev.dataTransfer &&
        ev.dataTransfer.files &&
        ev.dataTransfer.files[0];
      if (f) this.prepareFile(f);
    },
    onDragOver(ev) {
      ev.preventDefault();
    },
  },
  mounted() {
    document.addEventListener("paste", this.pasteHandler);
    document.addEventListener("dragover", this.onDragOver);
    document.addEventListener("drop", this.onDrop);
  },
  beforeDestroy() {
    document.removeEventListener("paste", this.pasteHandler);
    document.removeEventListener("dragover", this.onDragOver);
    document.removeEventListener("drop", this.onDrop);
    if (
      this.preview &&
      typeof this.preview === "string" &&
      this.preview.startsWith("blob:")
    ) {
      try {
        URL.revokeObjectURL(this.preview);
      } catch (e) {}
    }
  },
};
</script>

<style scoped>
.uploader-container {
  min-width: 40%;
  max-width: 60em;
  margin: 1rem auto;
  padding: 1rem;
  box-sizing: border-box;
  color: #e8e8e8;
  font-family: "Roboto Mono", monospace;
}

hr {
  border: none;
  height: 1px;
  background: rgba(255, 255, 255, 0.06);
  margin: 0.5rem 0;
}

.controls {
  display: flex;
  flex-direction: row;
  gap: 0.75rem;
  align-items: center;
  margin: 0.75rem 0;
  flex-wrap: wrap;
}

.hidden {
  display: none;
}

.btn-choose {
  display: block;
  width: 100%;
  background: #2d7eff;
  color: white;
  padding: 10px 14px;
  border-radius: 0px;
  cursor: pointer;
  text-decoration: none;
  text-align: center;
  box-sizing: border-box;
}

.btn-upload {
  display: block;
  width: 100%;
  background: #1e8e3e;
  color: white;
  padding: 10px 14px;
  border-radius: 0px;
  cursor: pointer;
  border: none;
  text-align: center;
  box-sizing: border-box;
}

.btn-retry {
  display: block;
  width: 100%;
  background: transparent;
  color: #bfe3ff;
  border: 1px solid rgba(191, 227, 255, 0.08);
  padding: 10px;
  border-radius: 0px;
  text-align: center;
  box-sizing: border-box;
}

.btn-remove {
  display: block;
  width: 100%;
  background: #d32f2f;
  color: #ffffff;
  padding: 10px 14px;
  border-radius: 0px;
  cursor: pointer;
  text-align: center;
  box-sizing: border-box;
  border: none;
}

.btn-cancel {
  background: #d32f2f;
  color: #ffffff;
  border: none;
  padding: 6px 8px;
  border-radius: 0px;
  cursor: pointer;
}

.meta-row {
  margin-top: 0.25rem;
  color: #9fb0c8;
}

.preview {
  margin-top: 0.75rem;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 0.75rem;
}

.preview-thumb {
  cursor: pointer;
  display: inline-block;
  border-radius: 6px;
  overflow: hidden;
  background: #000;
  box-shadow: 0 6px 18px rgba(0, 0, 0, 0.45);
  max-width: 40%;
  max-height: 12rem;
  width: auto;
}

.preview-video-small {
  width: 100%;
  height: 100%;
  max-height: 12rem;
  display: block;
  object-fit: cover;
  background: #000;
}

.preview-img {
  width: 100%;
  height: 100%;
  max-height: 12rem;
  display: block;
  object-fit: cover;
}

.preview-text {
  background: rgba(255, 255, 255, 0.03);
  padding: 0.5rem;
  border-radius: 4px;
  color: #dbe9ff;
  max-height: 15rem;
  overflow: auto;
}

.overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.75);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1200;
  padding: 1.25rem;
}
.overlay-content {
  max-width: 95%;
  max-height: 95%;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.75rem;
}
.overlay-media {
  border-radius: 8px;
  max-width: 100%;
  max-height: 80vh;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.6);
  background: #000;
}
.overlay-video {
  width: auto;
  height: auto;
  max-height: 80vh;
}
.overlay-image {
  width: auto;
  height: auto;
  max-height: 80vh;
}
.overlay-actions {
  display: flex;
  gap: 0.5rem;
  justify-content: space-between;
  margin-top: 0.25rem;
  width: 100%;
}
.overlay-actions > button {
  flex: 1 1 0;
  min-width: 0;
  padding: 10px 12px;
  border-radius: 0px;
}

.progress {
  margin-top: 0.75rem;
}

.progress-bar {
  height: 0.5rem;
  background: linear-gradient(90deg, #2d7eff, #4d91ff);
  width: 0%;
  border-radius: 4px;
  transition: width 0.2s ease;
}

.result {
  margin-top: 0.75rem;
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.result-input {
  flex: 1;
  padding: 6px;
  border-radius: 4px;
  border: none;
  background: #dfefff;
  color: #04293a;
}

.btn-copy {
  background: #1e8e3e;
  color: white;
  padding: 6px 10px;
  border-radius: 0px;
  border: none;
  cursor: pointer;
}

.error {
  margin-top: 0.75rem;
  color: #ffdddd;
  background: rgba(255, 0, 0, 0.06);
  padding: 0.5rem;
  border-radius: 4px;
}

.footer {
  margin-top: 1rem;
  color: #cfe8ff;
  font-size: 0.9rem;
}
</style>
