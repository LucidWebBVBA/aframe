#!make
MAKEFLAGS += --silent

PKGVERSION = $(shell node -pe "require('./package.json').version")

node_modules: package.json
	@echo "Installing @lucidweb/aframe dependencies..."
	npm install

link: node_modules
	@echo "Linking @lucidweb/aframe"
	@npm link

build: node_modules
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

release-major: build
	@echo "Current version is ${PKGVERSION}"
	@echo "Building major version..."
	git add dist/aframe-master.min.*
	npm version major -m "release(major): %s"

prerelease-major: build
	@echo "Current version is ${PKGVERSION}"
	@echo "Building premajor version..."
	git add dist/aframe-master.min.*
	npm version premajor -m "release(premajor): %s"

release-minor: build
	@echo "Current version is ${PKGVERSION}"
	@echo "Building minor version..."
	git add dist/aframe-master.min.*
	npm version minor -m "release(minor): %s"

prerelease-minor: build
	@echo "Current version is ${PKGVERSION}"
	@echo "Building preminor version..."
	git add dist/aframe-master.min.*
	npm version minor -m "release(preminor): %s"

release-patch: build
	@echo "Current version is ${PKGVERSION}"
	@echo "Building patch version..."
	git add dist/aframe-master.min.*
	npm version patch -m "release(patch): %s"

prerelease-patch: clean-dist build
	@echo "Current version is ${PKGVERSION}"
	@echo "Building prepatch version..."
	git add dist/aframe-master.min.*
	npm version patch -m "release(prepatch): %s"

clean-dist:
	@echo "Removing dist"
	rm -rf dist
	mkdir -p dist

clean:
	@echo "Removing node_modules"
	rm -rf node_modules
	@echo "Removing dist"
	rm -rf dist

.PHONY: build build-dev link
.PHONE: clean clean-dist
.PHONE: release-major release-minor release-patch
.PHONE: prerelease-major prerelease-minor prerelease-patch
