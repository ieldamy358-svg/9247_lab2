
# Defaults (override on the command line)
DIR           ?= monitored
MALICIOUS_DIR ?= malicious
INTERVAL      ?= 5

# create quarantine directory if missing
prebuild:
	mkdir -p $(MALICIOUS_DIR)

# run the antivirus daemon
run: prebuild
	./antivirusud.sh $(DIR) $(MALICIOUS_DIR) $(INTERVAL)

# run the restore tool
restore: prebuild
	./restore.sh $(DIR) $(MALICIOUS_DIR)

# remove snapshot files
clean:
	rm -f directory-info.last directory-info.new

.PHONY: prebuild run restore clean
