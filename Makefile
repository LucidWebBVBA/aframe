#!make
MAKEFLAGS += --silent

PKGVERSION = $(shell node -pe "require('./package.json').version")

node_modules: package.json
	@echo "Installing @lucidweb/aframe dependencies..."
	npm install

link: node_modules
	@echo "Linking @lucidweb/aframe"
	@npm link

build: clean-dist node_modules
	@echo "Building minified version..."
	npm run browserify -s -- --debug -p [minifyify --map aframe-master.min.js.map --output dist/aframe-master.min.js.map] -o dist/aframe-master.min.js
	@echo "Generated dist/aframe-master.min.js"
	@ls -alh dist/aframe-master.min.*

build-dev: node_modules
	@echo "Building unminified version..."
	npm run browserify -s -- --debug | ./node_modules/.bin/exorcist dist/aframe-master.js.map > dist/aframe-master.js
	@echo "Generated dist/aframe-master.js"
	@ls -alh dist/aframe-master.js
	@ls -alh dist/aframe-master.js.map

release-major: git-stash clean-dist build build-dev
	@echo "Current version is ${PKGVERSION}"
	@echo "Building major version..."
	git add dist/aframe-master.*
	npm version major -m "release(major): %s" -f

prerelease-major: git-stash clean-dist build build-dev
	@echo "Current version is ${PKGVERSION}"
	@echo "Building premajor version..."
	git add dist/aframe-master.*
	npm version premajor -m "release(premajor): %s" -f --preid=beta

release-minor: git-stash clean-dist build build-dev
	@echo "Current version is ${PKGVERSION}"
	@echo "Building minor version..."
	git add dist/aframe-master.*
	npm version minor -m "release(minor): %s" -f

prerelease-minor: git-stash clean-dist build build-dev
	@echo "Current version is ${PKGVERSION}"
	@echo "Building preminor version..."
	git add dist/aframe-master.*
	npm version preminor -m "release(preminor): %s" -f --preid=beta

release-patch: git-stash clean-dist build build-dev
	@echo "Current version is ${PKGVERSION}"
	@echo "Building patch version..."
	git add dist/aframe-master.*
	npm version patch -m "release(patch): %s" -f

prerelease-patch: git-stash clean-dist build build-dev
	@echo "Current version is ${PKGVERSION}"
	@echo "Building prepatch version..."
	git add dist/aframe-master.*
	npm version prepatch -m "release(prepatch): %s" -f --preid=beta

git-push:
	git push
	git push --tags

git-check-clean:
	git diff-index --quiet HEAD

git-stash:
	@echo "Stashing git changes"
	git stash

git-stash-pop:
	@echo "Unstashing previous git changes"
	git stash pop

clean-dist:
	@echo "Removing dist"
	rm -rf dist
	mkdir -p dist

clean:
	@echo "Removing node_modules"
	rm -rf node_modules
	@echo "Removing dist"
	rm -rf dist

prepublish:
	@echo "Publishg ${PKGVERSION} (@beta)"
	npm publish --access restricted --tag beta
dry-prepublish:
	@echo "Publishg ${PKGVERSION} (@beta)"
	npm publish --access restricted --tag beta --dry

publish:
	@echo "Publishing ${PKGVERSION}"
	npm publish --access restricted
dry-publish:
	@echo "Publishing ${PKGVERSION}"
	npm publish --access restricted --dry


.PHONY: build build-dev link
.PHONY: clean clean-dist
.PHONY: git-stash git-stash-pop git-check-clean git-push
.PHONY: release-major release-minor release-patch
.PHONY: prerelease-major prerelease-minor prerelease-patch
.PHONY: publish dry-publish prepublish dry-prepublish
