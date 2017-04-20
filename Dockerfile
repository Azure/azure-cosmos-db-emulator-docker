# DocumentDB Emulator Dockerfile

# Indicates that the windowsservercore image will be used as the base image.
FROM microsoft/windowsservercore

# Metadata indicating an image maintainer.
MAINTAINER mominag@microsoft.com

# Add the DocumentDB installer msi into the package
ADD https://aka.ms/documentdb-emulator c:\\DocumentDBEmulator\\DocumentDB.Emulator.msi

# Copy misc scripts into the package
COPY package_scripts\\startemu.cmd c:\\DocumentDBEmulator\\startemu.cmd
COPY package_scripts\\getaddr.ps1 c:\\DocumentDBEmulator\\getaddr.ps1
COPY package_scripts\\exportcert.ps1 c:\\DocumentDBEmulator\\exportcert.ps1
COPY package_scripts\\importcert.ps1 c:\\DocumentDBEmulator\\importcert.ps1

# Install the MSI
RUN echo "Starting Installer"
RUN powershell.exe -Command $ErrorActionPreference = 'Stop'; \
   Start-Process 'msiexec.exe' -ArgumentList '/i','c:\DocumentDBEmulator\DocumentDB.Emulator.msi','/qn' -Wait
RUN echo "Installer Done"

# Expose the required network ports
EXPOSE 8081
EXPOSE 10250
EXPOSE 10251
EXPOSE 10252
EXPOSE 10253
EXPOSE 10254

# Start the interactive shell
CMD [ "c:\\DocumentDBEmulator\\startemu.cmd" ]
