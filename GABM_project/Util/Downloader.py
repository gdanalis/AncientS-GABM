import requests, tarfile, os
import GABM_project.Strings.paths as pathStrings

class Downloader():
    def __init__(self):
        self.url = "https://ccl.northwestern.edu/netlogo/6.4.0/NetLogo-6.4.0-64.tgz"
        return

    def download_netlogo(self):
        current_dir = os.path.dirname(os.path.abspath(__file__))
        target_dir = current_dir
        for _ in range(2):
            target_dir = os.path.dirname(target_dir)
        self.netlogo_dir = os.path.join(target_dir, "NetLogo-6.4.0-64")

        if os.path.exists(self.netlogo_dir):
            print(f"Folder already exists: {self.netlogo_dir}. Skipping download.")
            return

        filename = "NetLogo-6.4.0-64.tgz"
        save_path = os.path.join(target_dir, filename)

        response = requests.get(self.url, stream=True)
        response.raise_for_status()
        print(f"Downloading {filename} to {target_dir} ...")
        with open(save_path, "wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        print("Download complete.")

        print(f"Extracting {save_path} to {target_dir} ...")
        with tarfile.open(save_path, "r:gz") as tar:
            tar.extractall(path=target_dir)
        print("Extraction complete.")

        extracted_folder = os.path.join(target_dir, "NetLogo-6.4.0")
        if os.path.exists(extracted_folder):
            os.rename(extracted_folder, self.netlogo_dir)

        os.remove(save_path)
        print(f"Deleted the archive {save_path}.")