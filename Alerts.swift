//
//  OpenFunctions.swift
//  Video Editor
//
//  Created by Владимир Воробьев on 15.12.2022.
//

import Foundation
import UIKit

public enum VideoEditorErrors: String, Error{

    case noError = ""
    
    case authorizationError = "Нет разрешения на пользование фото библиотекой. Вы можете установить его в Настройках"
    case authorizationLimited = "у вас ограничен выбор видео. Вы можете изменить это в приложении Настройки"
    //VideoCollectionError
    case fetchError = "Фото и видео не найдено! Проверьте интернет (ICloud)"
    case noVideoError = "Видео файлов не найдено!"
    case urlUnreadable = "Данный файл не доступен. Поробуйте зайти в приложение ФОТО и сохранить его ещё раз"

//MusicTableError
    case urlClosed = "Данный файл не доступен. Выберите купленный файл."

//ComposeError
    case videoTrackCreationError = "Ошибка создания видео дорожки"
    case compositionVideoTrackArrayError = "Ошибка создания видео композиции"
    case audioTrackCreationError = "Ошибка создания звуковой дорожки"
    case compositionAudioTrackArrayError = "Ошибка создания звуковой композиции"

//EditorError
    case urlCreationError = "Ошибка создантя URL"
    case fileDeletionError = "Ошибка удаления файла"
    case assetComposerError = "Ошибка создания композиции"
    case exportSessionError = "Ошибка выгрузки композиции"
    case recordError = "Ошибка записи файла"

}


func alertCall (_ sender: UIViewController, _ title: String?, _ message: String?) {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(.init(title: "OK", style: .default, handler: nil))
    sender.present(alertController, animated: true, completion: nil)
}

