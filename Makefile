default: copy

VERSION=1.0.1a

COPY_PATH=$$HOME/.local/share/atlauncher/instances/Minecraft1211withFabric/shaderpacks/

copy:
	 cp -rf "$$PWD" $(COPY_PATH)

clean:
	rm *.zip
zip:
	zip -r0 wisp_$(VERSION).zip shaders
