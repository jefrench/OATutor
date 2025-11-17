# ===============================================
# OATutor Build System
# ===============================================

DATE := $(shell date +"%Y-%m-%d_%H-%M-%S")
REPO_PATH := /Users/jenniferkamrin/Documents/git/OATutor
CONTENT_PATH := $(REPO_PATH)/src/content-sources/oatutor/Content
BANK_URL := $(CONTENT_PATH)/Content-Files/Problem Bank URL.xlsx
TOOL_SCRIPT := $(CONTENT_PATH)/OATutor-Tooling/content_script/final.py
SHEET_SCRIPT := $(CONTENT_PATH)/OATutor-Tooling/content_script/process_sheet.py
GOOGLE_SHEET := 1dHCRJHbUrJD6DKG3pSXFsR-f6D3fTwQO7eWaGzq_76s
URL_SHEET := 1H4hLDt8UDeuaMb-YkHTtieDxbJVKUjXqYAIUJi-EDGE

# Define course names for multi-sheet builds
SHEETS := "1.1 Definitions of Exp and Log" "1.2 Domains and Constraints" "1.3 Log and Exp are Inverses"

.PHONY: all local sheet book move start deploy clean

# -----------------------------------------------
# Default target
# -----------------------------------------------
all: book

# -----------------------------------------------
# 1️⃣ Local build (Excel-based) DON'T USE ANYMORE
# -----------------------------------------------
local:
	@echo "🚀 Starting OATutor LOCAL build..."
	cd $(CONTENT_PATH) && python3 $(TOOL_SCRIPT) local "$(BANK_URL)"
	$(MAKE) move


# -----------------------------------------------
# 3️⃣ Local test (runs npm start) DON't USe ANYMORe
# -----------------------------------------------
start:
	@echo "🧪 Starting local OATutor test site..."
	cd $(REPO_PATH) && npm install
	cd $(REPO_PATH) && npm start

# -----------------------------------------------
# 2️⃣ Google Sheet build (multi-sheet) TESTING PURPOSES/DON"T USE
# -----------------------------------------------
sheet:
	@echo "🚀 Starting OATutor SHEET build..."
	@for sheet_name in $(SHEETS); do \
		echo "📄 Processing $(sheet_name)..."; \
		cd $(CONTENT_PATH) && python3 $(SHEET_SCRIPT) online "$(GOOGLE_SHEET)" "$$sheet_name"; \
	done

# -----------------------------------------------
# 1️⃣ Google Sheet build (book)
# -----------------------------------------------
# Automatically detects if a 'full' build is needed based on the content-pool
#	@echo "🚀 Starting OATutor BOOK build..."
#	cd $(CONTENT_PATH) && python3 $(TOOL_SCRIPT) online "$(URL_SHEET)"
#	$(MAKE) move
book:
	@echo "🚀 Checking content status..."
	@if [ ! -d "$(REPO_PATH)/src/content-sources/oatutor/content-pool" ] || [ -z "$$(ls -A $(REPO_PATH)/src/content-sources/oatutor/content-pool 2>/dev/null)" ]; then \
		echo "📢 No content found in content-pool. Running FULL build..."; \
		cd $(CONTENT_PATH) && python3 $(TOOL_SCRIPT) online "$(URL_SHEET)" full; \
	else \
		echo "📢 Content detected. Running INCREMENTAL build..."; \
		cd $(CONTENT_PATH) && python3 $(TOOL_SCRIPT) online "$(URL_SHEET)"; \
	fi
	$(MAKE) move


# -----------------------------------------------
# Move and prep content after build
# -----------------------------------------------
move:
	@echo "📦 Moving and preparing content files..."
	cd $(REPO_PATH)/src/content-sources/oatutor && mkdir -p content-pool bkt-params
	rsync -av --update "$(REPO_PATH)/src/content-sources/oatutor/OpenStax Content/" "$(REPO_PATH)/src/content-sources/oatutor/content-pool/" || echo "⚠️ No files to move"
	cd $(REPO_PATH)/src/content-sources/oatutor && mv bktParams.json bkt-params/defaultBKTParams.json || echo "⚠️ bktParams.json missing"
	cd $(REPO_PATH)/src/content-sources/oatutor && cp bkt-params/defaultBKTParams.json bkt-params/experimentalBKTParams.json
	@echo "✅ Content moved successfully."


# -----------------------------------------------
# 2️⃣ Google Sheet build (fullbook)
# -----------------------------------------------
# Automatically does a 'full' build
fullbook:
	@echo "🚀 Starting OATutor BOOK build..."
	cd $(CONTENT_PATH) && python3 $(TOOL_SCRIPT) online "$(URL_SHEET)" full
	$(MAKE) move



# -----------------------------------------------
# 3️⃣ Deploy to production (Safe branch switching)
# -----------------------------------------------
deploy:
	@echo "🚀 Preparing deployment..."
	@# Switch to gh-pages if it exists, otherwise create it
	git checkout gh-pages || git checkout -b gh-pages
	@echo "📦 Installing and Building..."
	npm install
	npm run build
	@echo "📤 Committing and Pushing..."
	git add docs/*
	git commit -m "Deploy build on $(DATE)"
	git push origin gh-pages --force
	@echo "🔙 Returning to main branch..."
	git checkout main

# -----------------------------------------------
# 4️⃣ Deploy to production (runs npm run deploy)
# -----------------------------------------------
deployold:
	@echo "🚀 Deploying OATutor to gh-pages..."
	cd $(REPO_PATH) && git checkout -b gh-pages
	cd $(REPO_PATH) && npm install
	cd $(REPO_PATH) && npm run build
	cd $(REPO_PATH) && git add docs/*
	cd $(REPO_PATH) && git commit -m "Deploy build on $(DATE)"
	cd $(REPO_PATH) && git push --set-upstream origin gh-pages
	

# -----------------------------------------------
# Clean old build artifacts and gh-pages branch
# -----------------------------------------------
clean:
	@echo "🧹 Cleaning project..."
	@pkill -f node || echo "⚠️ No Node processes found"
	@rm -rf $(REPO_PATH)/node_modules
	@npm cache clean --force
	@echo "💀 Node processes stopped and environment cleaned."
	git checkout main
	git branch -D gh-pages || true

