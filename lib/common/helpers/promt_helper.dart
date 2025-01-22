class PromptHelper {
  PromptHelper._();

  static String getPromt(){
    return '''
Berikut adalah gambar paspor. Ekstrak informasi dari gambar ini dan berikan data dalam format JSON berikut. Pastikan untuk mengambil data mrzCode dari 2 baris kode paspor yang berada di bagian bawah paspor, termasuk juga karakternya. Jangan tambahkan penjelasan, deskripsi, atau kalimat tambahan apa pun di luar JSON.

Format JSON yang diinginkan:
{
  "type": "Tipe paspor, seperti P",
  "countryCode": "Kode negara, seperti IDN",
  "passportNumber": "Nomor paspor",
  "fullName": "Nama lengkap",
  "nationality": "Kewarganegaraan",
  "dateOfBirth": "Tanggal lahir dalam format YYYY-MM-DD",
  "gender": "Jenis kelamin, M atau F",
  "placeOfBirth": "Tempat lahir",
  "dateOfIssue": "Tanggal dikeluarkan dalam format YYYY-MM-DD",
  "dateOfExpiry": "Tanggal habis berlaku dalam format YYYY-MM-DD",
  "registrationNumber": "Nomor registrasi",
  "issuingAuthority": "Otoritas yang mengeluarkan paspor",
  "mrzCode": "Ambil dari kode paspor di bagian bawah paspor"
}

Jika gambar yang diberikan bukan "halaman identitas paspor", hanya kembalikan 400 tanpa penjelasan tambahan, deskripsi, atau kalimat lain, dan tanpa menghasilkan JSON kosong.
''';
  }
}
