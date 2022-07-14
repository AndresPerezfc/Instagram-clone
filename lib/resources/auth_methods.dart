import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/resources/storage_methods.dart';
import 'package:instagram_flutter/models/user.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registro de usuario

  Future<String> signUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Ha ocurrido un error";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty) {
        // Requistrar usuariofile != null

        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        print(cred.user!.uid);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        // añadir usuario a la base de datos

        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          email: email,
          bio: bio,
          followers: [],
          following: [],
          photoUrl: photoUrl,
        );

        await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());

        //

        res = "Registrado con exito";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = 'El email es invalido';
      } else if (err.code == 'weak-password') {
        res = 'La contraseña es demasiado debil';
      } else if (err.code == 'email-already-in-use') {
        res = 'El correo electrónico ya ha sido utilizado';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Login de usuarios
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Ha ocurrido un error';

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "Inicio exitoso";
      } else {
        res = "Por favor ingrese todos los campos";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-passoword') {}
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
